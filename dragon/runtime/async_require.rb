# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# async_require.rb has been released under MIT (*only this file*).

module GTK
  class Runtime
    module AsyncRequire
      def async_require_init
        @reload_list = []

        # schema for reload_list_history
        # { PATH: { current: { path: PATH,
        #                      global_at: Fixnum,
        #                      event: (:reload_queued|:processing|reload_completed) },
        #           history: [{ path: PATH,
        #                             global_at: Fixnum,
        #                             event: (:reload_queued|:processing|reload_completed) }]}}
        @reload_list_history = {}

        @reload_debounce = 0
      end

      def most_recent_reload_history path
        return nil unless @reload_list_history[path]
        return nil unless @reload_list_history[path][:history]
        return @reload_list_history[path][:history].last
      end

      def mark_ruby_file_for_reload path
        @reload_list_history[path] ||= { current: {}, history: [] }
        info = @reload_list_history[path]
        recent = (most_recent_reload_history path)

        return if recent && (((recent[:global_at] || 0) + 60) > Kernel.global_tick_count)
        return if info && info[:current] && info[:current][:event] && (((info[:global_at] || 0) + 60) > Kernel.global_tick_count)

        @reload_list_history[path][:current]   = { path: path, global_at: Kernel.global_tick_count, event: :reload_queued  }
        @reload_list_history[path][:history] ||= []
        @reload_list_history[path][:history]  << { path: path, global_at: Kernel.global_tick_count, event: :reload_queued  }

        log "** INFO: =#{path}= queued to load via ~require~. (#{Kernel.global_tick_count}, #{Kernel.tick_count})", subsystem="Engine"

        if @load_status == :ready
          @reload_list << path
          @reload_list.uniq!
          __require_sync__ path
        else
          @reload_list << path
          @reload_list.uniq!
        end
      rescue Exception => e
        raise e, "* EXCEPTION: ~Runtime#mark_ruby_file_for_reload~ failed for =#{path}=.\n#{e}"
      end

      def get_ruby_reload_list
        return [] if @reload_list.length == 0
        @reload_list.each do |r|
          @reload_list_history[r]           ||= {}
          @reload_list_history[r][:current]   = { path: r, global_at: Kernel.global_tick_count, event: :processing }
          @reload_list_history[r][:history] ||= []
          @reload_list_history[r][:history]  << { path: r, global_at: Kernel.global_tick_count, event: :processing }
        end
        @exception_occured = false
        @is_reloading = true
        @reload_list
      end

      def reload_complete
        return unless @is_reloading
        @is_reloading = false

        if !@exception_occured
          unpause!
          @console.hide if @console.show_reason == :exception || @console.show_reason == :exception_on_load
        end

        @reload_list_history.keys.each do |k|
          if (@reload_list_history[k][:current][:event] == :processing) || (@reload_list_history[k][:current][:event] == :reload_queued)
            log "* INFO: =#{k}= reloaded. (#{Kernel.global_tick_count}, #{Kernel.tick_count})", subsystem="Engine"
            @reload_list_history[k][:current]  = { path: k, global_at: Kernel.global_tick_count, event: :reload_completed }
            @reload_list_history[k][:history] << { path: k, global_at: Kernel.global_tick_count, event: :reload_completed }
          end
        end

        @last_reload_complete_global_at = Kernel.global_tick_count
        $layout.reset if $layout
        $gtk.reset_framerate_calculation

        main_rb_loaded!
      end

      def on_file_reloaded file
      end

      def main_rb_reload_completed?
        return (@reload_list_history['app/main.rb'] &&
                @reload_list_history['app/main.rb'][:history] &&
                @reload_list_history['app/main.rb'][:history].find { |h| h[:event] == :reload_completed }) ||
               (@reload_list_history['app/main.rbc'] &&
                @reload_list_history['app/main.rbc'][:history] &&
                @reload_list_history['app/main.rbc'][:history].find { |h| h[:event] == :reload_completed })
      end

      def main_rb_loaded!
        @new_methods ||= important_instance_methods
        new_methods = important_instance_methods - @new_methods

        if new_methods.length > 0
          log <<-S
* INFO: New methods discovered.
#{new_methods.map { |m| "** #{m.inspect}" }.join("\n")}
S
          @new_methods = important_instance_methods
        end

        process_load_status
      end

      def important_instance_methods
        Object.instance_methods + dollar_sign_game_methods
      end

      def dollar_sign_game_methods
        return [] if !$game
        return $game.class.instance_methods
      end

      def process_load_status
        return if @load_status == :ready
        return if pending_reload?

        if main_rb_reload_completed?
          @load_status = :ready
          log "* INFO: ~GTK::Runtime#load_status~ set to ~:ready~.", subsystem="Engine"
          Kernel.tick_count = -1
          Kernel.global_tick_count = -1
          $gtk.write_file_root (File.join backup_directory, "boot.txt"), Time.now.to_i.to_s
          $top_level.boot @args if $top_level.respond_to? :boot
          @args.state.tick_count = -1
          Kernel.global_tick_count = -1
          Kernel.tick_count = -1
          reset_all_mtimes
        end
      end

      def load_status
        @load_status
      end

      def pending_reload?
        @reload_list_history.any? do |key, value|
          value[:current][:event] == :reload_queued ||
          value[:current][:event] == :processing
        end
      end

      def reload_ruby_file file
        ext = File.extname(file)
        return false unless ext == ".rb" || ext == ".rbc"
        return true if @suppress_hotload
        backup_create file
        syntax = (@ffi_file.read file) || ''
        return true if syntax.strip.length == 0

        # this indicates that main.rb contained a syntax error when
        # first loaded and the dev updated main.rb (in an attempt to fix the syntax error).
        # set the Kernel.tick_count and global_tick_count to -1 which emulates a first time
        # start up of DR -> causes load_main_rb to be invoked.
        if @load_status == :main_rb_load_error_shown
          Kernel.tick_count = -1
          Kernel.global_tick_count = -1
          @load_status = :dragonruby_started
        end

        okay = true
        if ext == ".rb"
          syntax_check_result = @ffi_mrb.parse syntax
          okay = (syntax_check_result == "Syntax OK")
        end

        if okay
          mark_ruby_file_for_reload file
          log_debug "Reloaded #{file}. (#{Kernel.global_tick_count})", subsystem="Engine"
          notify_subdued!
          return true
        else
          # handle a special case where a syntax error exists in main.rb on startup
          raise <<~S
                ** Failed to load/reload #{file}.
                #{syntax_check_result}

                S
        end
      rescue Exception => e
        pretty_print_exception_and_export! e
        pause!
        self.show_console :exception
        return false
      end

      def load_main_rb
        return if @load_status != :dragonruby_started
        if @ffi_file.path_exists('app/main.rb') || @ffi_file.path_exists('app/main.rbc')
          require 'app/main.rb'
        end
      rescue Exception => e
        # if an exception occurs, it means that there was a syntax error
        # in main.rb at first launch
        @load_status = :main_rb_load_failed
      end
    end # GTK::Runtime::AsyncRequire
  end # GTK::Runtime
end # GTK
