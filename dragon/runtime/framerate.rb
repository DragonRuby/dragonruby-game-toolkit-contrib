# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# framerate.rb has been released under MIT (*only this file*).

module GTK
  class Runtime
    module Framerate
      def framerate_init
        @tick_time = Time.new.to_i
      end

      def delta_framerate
        (current_framerate || 0) - (@previous_framerate || 0)
      end

      def disable_framerate_warning!
        @framerate_disable_warning = true
        log "Framerate warning disabled. To re-enable, call ~$gtk.enable_framerate_warning!~"
      end

      def enable_framerate_warning!
        @framerate_disable_warning = false
        log "Framerate warning re-enabled. To disable, call ~$gtk.disable_framerate_warning!~"
      end

      def reset_framerate_calculation
        @tick_speed_sum = 0
        @tick_speed_count = 10
        @framerate_warning_message_shown_at = -1
      end

      def framerate_should_show_warning?
        return false if @framerate_disable_warning
        return false if Kernel.global_tick_count < 0
        return false if (Kernel.global_tick_count - (@last_reset_global_at || 0)) < 1800
        return false if (Kernel.global_tick_count - (@last_reload_complete_global_at || 0)) < 1800
        has_debounce_elapsed = if @framerate_warning_message_shown_at == -1
                                 true
                               else
                                 (Kernel.global_tick_count - @framerate_warning_message_shown_at) > 1800
                               end
        !(@console.visible? || @recording.is_replaying?) && has_debounce_elapsed
      end

      def check_framerate
        if @framerate_diagnostics_requested
          log "================================"
          @framerate_diagnostics_requested = false
          log framerate_get_diagnostics if args.inputs.keyboard.has_focus
        end

        if !@paused
          if @tick_time
            @tick_speed_count += 1
            @tick_speed_sum += Time.now.to_i - @tick_time
            if @tick_speed_count > 120
              if framerate_below_threshold?
                @framerate_warning_message_shown_at ||= -1
                if framerate_should_show_warning?
                  GTK::Log.puts_important("* WARNING: Framerate below 30fps for over 120 frames.", message_code: [:framerate_warning])
                  log(framerate_warning_message)
                  @framerate_warning_message_shown_at = Kernel.global_tick_count
                  @framerate_captured_diagnostics = {
                    solids_length: @args.outputs.solids.length,
                    static_solids_length: @args.outputs.static_solids.length,
                    sprites_length: @args.outputs.sprites.length,
                    static_sprites_length: @args.outputs.static_sprites.length,
                    primitives_length: @args.outputs.primitives.length,
                    static_primitives_length: @args.outputs.static_primitives.length,
                    labels_length: @args.outputs.labels.length,
                    static_labels_length: @args.outputs.static_labels.length,
                    lines_length: @args.outputs.lines.length,
                    static_lines_length: @args.outputs.static_lines.length,
                    borders_length: @args.outputs.borders.length,
                    static_borders_length: @args.outputs.static_borders.length,
                    debug_length: @args.outputs.debug.length,
                    static_debug_length: @args.outputs.static_debug.length,
                  }
                end
              end
            end
          end

          @tick_time = Time.new.to_i
        else
          reset_framerate_calculation
        end
      rescue
        reset_framerate_calculation
      end

      def framerate_diagnostics
        # request framerate diagnostics to be printed at the end of tick
        @framerate_diagnostics_requested = true
      end

      def framerate_below_threshold?
        return current_framerate < 30 && Kernel.tick_count > 60
      end

      def current_framerate
        return 60 if !@tick_speed_sum || !@tick_speed_sum
        r = 100.fdiv(@tick_speed_sum.fdiv(@tick_speed_count) * 100)
        if (r.nan? || r.infinite? || r > 58)
          r = 60
        else
          r = r.round
        end
        r || 60
      rescue
        60
      end
    end # module Framerate
  end # end class Runtime
end # end module GTK
