# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# console.rb has been released under MIT (*only this file*).

# Contributors outside of DragonRuby who also hold Copyright:
# - Kevin Fischer: https://github.com/kfischer-okarin
# - Eli Raybon: https://github.com/eliraybon
# - mooff: https://github.com/awfulcooking

module GTK
  class Console
    include ConsoleDeprecated

    attr_accessor :show_reason, :log, :logo,
                  :animation_duration,
                  :max_log_lines, :max_history,
                  :last_command_errored, :last_command, :shown_at,
                  :archived_log, :last_log_lines, :last_log_lines_count,
                  :suppress_left_arrow_behavior, :command_set_at,
                  :toast_ids, :bottom,
                  :font_style, :menu,
                  :background_color, :spam_color, :text_color, :warn_color,
                  :error_color, :header_color, :code_color, :comment_color,
                  :debug_color, :unfiltered_color, :toggled_at

    def initialize
      @font_style = FontStyle.new(font: 'font.ttf', size_enum: -2, line_height: 1.1)
      @menu = Menu.new self
      @disabled = false
      @log_offset = 0
      @visible = false
      @toast_ids = []
      @archived_log = []
      @log = [ 'Console ready.' ]
      @max_log_lines = 1000  # I guess...?
      @max_history = 5000  # I guess...?
      @log_invocation_count = 0
      @command_history = []
      @command_history_index = -1
      @nonhistory_input = ''
      @logo = 'console-logo.png'
      @history_fname = 'logs/console_history.txt'
      @background_color = Color.new [0, 0, 0, 255]
      @header_color = Color.new [94, 170, 248]
      @header_2_color = Color.new [216, 95, 135]
      @header_3_color = Color.new [214, 134, 214]
      @code_color = Color.new [210, 168, 255]
      @comment_color = Color.new [0, 200, 100]
      @animation_duration = 1.seconds
      @shown_at = -1

      # these are the colors for text at various log levels.
      @spam_color = Color.new [160, 160, 160]
      @debug_color = Color.new [0, 255, 0]
      @text_color = Color.new [232, 232, 232]
      @warn_color = Color.new [255, 255, 0]
      @error_color = Color.new [255, 80, 80]
      @unfiltered_color = Color.new [0, 255, 255]
      @add_primitive_queue = []
      @clear_logs_request_queue = []

      load_history
    end

    def __to_color_or_raise__ m, value
      if value.is_a?(Array) && value.all? { |i| i.is_a? Numeric } && value.length == 3
        Color.new value
      elsif value.is_a?(Hash) && value[:r] && value[:g] && value[:b] && value.values.all? { |i| i.is_a? Numeric }
        Color.new [value[:r], value[:g], value[:b]]
      elsif value.is_a? Color
        value
      else
        raise <<~S
          * ERROR: Invalid argument #{value} for ~Console##{m}=~
          Example:
          #+begin_src
            GTK.console.#{m} = [30, 30, 30] # Array[r, g, b]
            GTK.console.#{m} = { r: 30, g: 30, b: 30 } # Hash
            GTK.console.#{m} = GTK::Console::Color.new([30, 30, 30])
          #+end_src
        S
      end
    end

    def background_color= value
      @background_color = __to_color_or_raise__ :background_color, value
    end

    def spam_color= value
      @spam_color = __to_color_or_raise__ :spam_color, value
    end

    def text_color= value
      @text_color = __to_color_or_raise__ :text_color, value
    end

    def warn_color= value
      @warn_color = __to_color_or_raise__ :warn_color, value
    end

    def error_color= value
      @error_color = __to_color_or_raise__ :error_color, value
    end

    def header_color= value
      @header_color = __to_color_or_raise__ :header_color, value
    end

    def code_color= value
      @code_color = __to_color_or_raise__ :code_color, value
    end

    def comment_color= value
      @comment_color = __to_color_or_raise__ :comment_color, value
    end

    def debug_color= value
      @debug_color = __to_color_or_raise__ :debug_color, value
    end

    def unfiltered_color= value
      @unfiltered_color = __to_color_or_raise__ :unfiltered_color, value
    end

    def console_text_width
      @console_text_width ||= ($gtk.logical_width - 20).idiv(font_style.letter_size.w)
    end

    def save_history
      $gtk.ffi_file.write_root @history_fname, (@command_history.reverse.join "\n")
    end

    def load_history
      @command_history.clear
      str = $gtk.ffi_file.read @history_fname
      return if str.nil?  # no history to load.

      str.chomp!("\n")  # Don't let endlines at the end cause extra blank line.
      str.chomp!("\r")
      str.each_line { |s|
        s.chomp!("\n")
        s.chomp!("\r")
        if s.length > 0
          @command_history.unshift s
          break if @command_history.length >= @max_history
        end
      }

      @command_history.uniq!
    end

    def disable
      @disabled = true
      @visible = false
    end

    def enable
      @disabled = false
    end

    def add_sprite obj
      @log_invocation_count += 1
      obj[:id] ||= "id_#{obj[:path]}_#{Time.now.to_i}".to_sym

      if @last_line_log_index &&
         @last_sprite_line.is_a?(Hash) &&
         @last_sprite_line[:id] == obj[:id]

        @log[@last_line_log_index] = obj
        return
      end

      @log << obj
      @last_line_log_index = @log.length - 1
      @last_sprite_line = obj
      nil
    end

    def __add_primitive__ obj
      if obj.is_a? Hash
        add_sprite obj
      else
        add_text obj
      end
      nil
    end

    def add_primitive obj, global_at: nil
      @add_primitive_queue << {
        global_at: global_at || Kernel.global_tick_count,
        primitive: obj
      }
      nil
    end

    def add_text obj, loglevel=-1
      # loglevel is one of the values of LogLevel in logging.h, or -1 to say "we don't care, colorize it with your special string parsing magic"
      loglevel = -1 if loglevel < 0
      loglevel = 5 if loglevel > 5  # 5 == unfiltered (it's 0x7FFFFFFE in C, clamp it down)
      loglevel = 2 if (loglevel == -1) && obj.start_with?('!c!')  # oh well
      colorstr = (loglevel != -1) ? "!c!#{loglevel}" : nil

      @last_log_lines_count ||= 1
      @log_invocation_count += 1

      str = obj.to_s

      log_lines = []

      str.each_line do |s|
        if colorstr.nil?
          s.wrapped_lines(self.console_text_width).each do |l|
            log_lines << l
          end
        else
          s.wrapped_lines(self.console_text_width).each do |l|
            log_lines << "#{colorstr}#{l}"
          end
        end
      end

      if log_lines == @last_log_lines && log_lines.length != 0
        @last_log_lines_count += 1
        new_log_line_with_count = @last_log_lines.last + " (#{@last_log_lines_count})"
        if log_lines.length > 1
          @log = @log[0..-(@log.length - log_lines.length)] + log_lines[0..-2] + [new_log_line_with_count]
        else
          @log = @log[0..-2] + [new_log_line_with_count]
        end
        return
      end

      log_lines.each do |l|
        @log.shift if @log.length > @max_log_lines
        @log << l
      end

      @last_log_lines_count = 1
      @last_log_lines = log_lines
      nil
    end

    def ready?
      visible? && @toggled_at.elapsed?(@animation_duration, Kernel.global_tick_count)
    end

    def hidden?
      !@visible
    end

    def visible?
      !!@visible
    end

    def open reason = nil
      show reason
    end

    def show reason = nil
      @shown_at = Kernel.global_tick_count
      @show_reason = reason
      toggle if hidden?
    end

    def hide
      if visible?
        if @cursor_visibilty_before_show == false
          $gtk.hide_cursor
        end
        toggle
        @archived_log += @log
        if @archived_log.length > @max_log_lines
          @archived_log = @archived_log.drop(@archived_log.length - @max_log_lines)
        end
        @log.clear
        @show_reason = nil
        clear_toast
      end
    end

    def close
      hide
    end

    def clear_toast
      @toasted_at = nil
      @toast_duration = 0
    end

    def toggle
      if !@visible
        @cursor_visibilty_before_show = $gtk.cursor_shown?
        $gtk.show_cursor
      else
        if @cursor_visibilty_before_show == false
          $gtk.hide_cursor
        end
      end
      @visible = !@visible
      @toggled_at = Kernel.global_tick_count
    end

    def currently_toasting?
      return false if hidden?
      return false unless @show_reason == :toast
      return false unless @toasted_at
      return false if @toasted_at.elapsed?(5.seconds, Kernel.global_tick_count)
      return true
    end

    def toast_extended id = nil, duration = nil, *messages
      if !id.is_a?(Symbol)
        raise <<-S
* ERROR:
args.gtk.console.toast has the following signature:

  def toast id, *messages
  end

The id property uniquely defines the message and must be
a symbol.

After that, you can provide all the objects you want to
look at.

Example:

  args.gtk.console.toast :say_hello,
                        \"Hello world.\",
                          Kernel.tick_count

Toast messages autohide after 5 seconds.

If you need to look at something for longer, use
args.gtk.console.perma_toast instead (which you can manually dismiss).

S
      end

      return if currently_toasting?
      return if @toast_ids.include? id
      @toasted_at = Kernel.global_tick_count
      log_once_info :perma_toast_tip, "Use console.perma_toast to show the toast for longer."
      dwim_duration = 5.seconds
      add_text "* toast :#{id}"
      puts "* TOAST: :#{id}"
      messages.each do |message|
        lines = message.to_s.wrapped_lines(self.console_text_width)
        dwim_duration += lines.length.seconds
        add_text "** #{message}"
        puts "** #{message}"
      end
      show :toast
      @toast_duration += duration || dwim_duration
      @toast_ids << id
      set_command "$gtk.console.hide"
    end

    def perma_toast id = nil, messages
      toast_extended id, 600.seconds, *messages
    end

    def toast id = nil, *messages
      toast_extended id, nil, *messages
    end

    def console_toggle_keys
      [
        :backtick,
        :tilde,
        :superscript_two,
        :section_sign,
        :ordinal_indicator,
        :circumflex,
      ]
    end

    def console_toggle_key_down? args
      args.inputs.keyboard.key_down.any? console_toggle_keys
    end

    def try_search_docs exception
      string_e = "#{exception}"
      @last_command_errored = true

      if (string_e.include? "wrong number of arguments")
        method_name = ((string_e.split ":")[0].gsub "'", "")
        if !(method_name.include? " ")
          results = (Kernel.__docs_search_results__ method_name)
          if !results.include? "* No results found."
            puts (results.join "\n")
            puts <<-S
* INFO: #{results.length} matches(s) found in DOCS for ~#{method_name}~ (see above).
You can search the documentation yourself using the following command in the Console:
#+begin_src ruby
  docs_search \"#{method_name}\"
#+end_src
S
            log_once_info :exported_search_results, "The search results above has been seen in logs/puts.txt and docs/search_results.txt."
          end
        end
      end
    rescue Exception => se
      puts <<-S
* FATAL: ~GTK::Console#try_search_docs~
There was an exception searching for docs (~GTK::Console#try_search_docs~). You might want to let DragonRuby know about this.
** INNER EXCEPTION
#{se}
S
    end

    def eval_the_set_command
      cmd = current_input_str.strip
      if cmd.length != 0
        @log_offset = 0
        prompt.clear

        @command_history.pop_back while @command_history.length >= @max_history
        @command_history.push_front cmd
        @command_history_index = -1
        @nonhistory_input = ''

        if cmd == 'quit' || cmd == ':wq' || cmd == ':q!' || cmd == ':q' || cmd == ':wqa'
          $gtk.request_quit
        elsif (cmd.start_with? "./dragonruby-publish") || (cmd.start_with? ".\\dragonruby-publish") || (cmd.start_with? "dragonruby-publish")
          # TODO: maybe kick off the itch wizard here ~$wizards.itch.start~
          puts "-> #{cmd}"
          puts <<-S
* INFO:
It looks like you are trying to publish your game. The dragonruby-publish
command must be run from your terminal (not the DragonRuby Console).
S
        else
          puts "-> #{cmd}"

          begin
            @last_command = cmd

            locals = (@locals ||= {})

            results = GTK::ConsoleEvaluator.evaluate cmd
           if results.nil?
              puts "=> nil"
            elsif results == :console_silent_eval
              # do nothing since the console is silent
            else
              if cmd.include?("docs") && (results.is_a? String) && (results.start_with? "*")
                puts "=>\n#{results}"
              else
                puts "=> #{results.inspect}"
              end
            end

            @last_command_errored = false
          rescue Exception => e
            try_search_docs e
            # if an exception is thrown and the bactrace includes something helpful, then show it
            if (e.backtrace || []).first && (e.backtrace.first.include? "(eval)")
              puts  "* EXCEPTION: #{e}"
            else
              puts  "* EXCEPTION: #{e}\n#{e.__backtrace_to_org__}"
            end
          end
        end
      end
    end

    def inputs_scroll_up_full? args
      return false if @disabled
      args.inputs.keyboard.key_down.pageup ||
        (args.inputs.keyboard.key_up.b && args.inputs.keyboard.key_up.control)
    end

    def scroll_to_bottom
      @log_offset = 0
    end

    def scroll_up_full
      @log_offset += lines_on_one_page
      @log_offset = @log.size if @log_offset > @log.size
    end

    def inputs_scroll_up_half? args
      return false if @disabled
      args.inputs.keyboard.ctrl_u || args.inputs.keyboard.ctrl_b
    end

    def scroll_up_half
      @log_offset += lines_on_one_page.idiv(2)
      @log_offset = @log.size if @log_offset > @log.size
    end

    def inputs_scroll_down_full? args
      return false if @disabled
      args.inputs.keyboard.key_down.pagedown ||
        (args.inputs.keyboard.key_up.f && args.inputs.keyboard.key_up.control)
    end

    def scroll_down_full
      @log_offset -= lines_on_one_page
      @log_offset = 0 if @log_offset < 0
    end

    def inputs_scroll_down_half? args
      return false if @disabled
      args.inputs.keyboard.ctrl_d || args.inputs.keyboard.ctrl_f
    end

    def inputs_clear_command? args
      return false if @disabled
      args.inputs.keyboard.escape || args.inputs.keyboard.ctrl_g
    end

    def scroll_down_half
      @log_offset -= lines_on_one_page.idiv(2)
      @log_offset = 0 if @log_offset < 0
    end

    def mouse_wheel_scroll args
      @inertia ||= 0

      if args.inputs.mouse.wheel
        if args.inputs.mouse.wheel.y > 0
          @inertia = 1
        elsif args.inputs.mouse.wheel.y < 0
          @inertia = -1
        end
      end

      if args.inputs.mouse.click
        @inertia = 0
      end

      return if @inertia == 0

      @inertia = (@inertia * 0.7)
      if @inertia > 0
        @log_offset += 1
      elsif @inertia < 0
        @log_offset -= 1
      end

      if @inertia.abs < 0.01
        @inertia = 0
      end

      if @log_offset > @log.size
        @log_offset = @log.size
      elsif @log_offset < 0
        @log_offset = 0
      end
    end

    def __paste__
      prompt << $gtk.ffi_misc.getclipboard
    end

    def __copy__
      $gtk.ffi_misc.setclipboard prompt.current_input_str
    end

    def process_inputs args
      if console_toggle_key_down? args
        args.inputs.text.clear
        toggle
        args.inputs.keyboard.clear if !@visible
      end

      return unless visible?

      args.inputs.text.each { |str| prompt << str }
      args.inputs.text.clear
      mouse_wheel_scroll args

      @log_offset = 0 if @log_offset < 0

      if args.inputs.keyboard.key_down.enter
        if slide_progress > 0.5
          # in the event of an exception, the console window pops up
          # and is pre-filled with $gtk.reset.
          # there is an annoying scenario where the exception could be thrown
          # by pressing enter (while playing the game). if you press enter again
          # quickly, then the game is reset which closes the console.
          # so enter in the console is only evaluated if the slide_progress
          # is atleast half way down the page.
          eval_the_set_command
        end
      elsif args.inputs.keyboard.key_down.v
        if args.inputs.keyboard.key_down.control || args.inputs.keyboard.key_down.meta
          __paste__
        end
      elsif args.inputs.keyboard.key_down.home
        prompt.move_cursor_home
      elsif args.inputs.keyboard.key_down.end
        prompt.move_cursor_end
      elsif args.inputs.keyboard.key_down.up
        if @command_history_index == -1
          @nonhistory_input = current_input_str
        end
        if @command_history_index < (@command_history.length - 1)
          @command_history_index += 1
          self.current_input_str = @command_history[@command_history_index].dup
        end
      elsif args.inputs.keyboard.key_down.down
        if @command_history_index == 0
          @command_history_index = -1
          self.current_input_str = @nonhistory_input
          @nonhistory_input = ''
        elsif @command_history_index > 0
          @command_history_index -= 1
          self.current_input_str = @command_history[@command_history_index].dup
        end
      elsif args.inputs.keyboard.key_down.left
        if args.inputs.keyboard.key_down.control || args.inputs.keyboard.key_down.alt
          prompt.move_cursor_left_word
        else
          prompt.move_cursor_left
        end
      elsif args.inputs.keyboard.key_down.right
        if args.inputs.keyboard.key_down.control || args.inputs.keyboard.key_down.alt
          prompt.move_cursor_right_word
        else
          prompt.move_cursor_right
        end
      elsif inputs_scroll_up_full? args
        scroll_up_full
      elsif inputs_scroll_down_full? args
        scroll_down_full
      elsif inputs_scroll_up_half? args
        scroll_up_half
      elsif inputs_scroll_down_half? args
        scroll_down_half
      elsif inputs_clear_command? args
        prompt.clear
        @command_history_index = -1
        @nonhistory_input = ''
      elsif args.inputs.keyboard.key_down.backspace
        prompt.backspace
      elsif args.inputs.keyboard.key_down.delete
        prompt.delete
      elsif args.inputs.keyboard.key_down.tab
        prompt.autocomplete
      end

      args.inputs.keyboard.key_down.clear
      args.inputs.keyboard.key_up.clear
      args.inputs.keyboard.key_held.clear
    end

    def write_primitive_and_return_offset(args, left, y, str, archived: false)
      if str.is_a?(Hash)
        padding = 10
        args.outputs.reserved << { x: left + 10, y: y + 5, w: str[:w], h: str[:h], path: str[:path], a: (255.0 * slide_progress).to_i }
        return str[:h] + padding
      else
        write_line args, left, y, str, archived: archived
        return line_height_px
      end
    end

    def write_line(args, left, y, str, archived: false)
      color = color_for_log_entry(str).to_h
      color.a = (255.0 * slide_progress).to_i
      color.a *= 0.5 if archived
      str = str[4..-1] if str.start_with?('!c!')  # chop off loglevel color
      args.outputs.reserved << font_style.label(x: left.shift_right(10), y: y, text: str, color: color)
    end

    def should_tick?
      return false if !@toggled_at
      return false if slide_progress == 0
      return false if @disabled
      return visible?
    end

    def logo_final_y
      @logo_final_y = Layout.rect(row: 0, h: 1).center_y
    end

    def slide_progress_bottom
      top - (h * slide_progress)
    end

    def render args
      return if !@toggled_at
      return if slide_progress == 0

      args.outputs.reserved << { x: left, y: slide_progress_bottom, w: w, h: h, path: :solid, **@background_color.mult_alpha(slide_progress).to_h }
      args.outputs.reserved << { x: 20,
                                 y: slide_progress_bottom.shift_up(logo_final_y - 44),
                                 w: 100,
                                 h: 100,
                                 path: @logo,
                                 a: (80.0 * slide_progress).to_i }

      y = slide_progress_bottom + 2  # just give us a little padding at the bottom.
      prompt.render args, x: left.shift_right(10), y: y
      y += line_height_px * 1.5
      args.outputs.reserved << line(y: y, color: @text_color.mult_alpha(slide_progress))
      y += line_height_px.to_f / 2.0

      ((@log.size - @log_offset) - 1).downto(0) do |idx|
        offset_after_write = write_primitive_and_return_offset args, left, y, @log[idx]
        y += offset_after_write
        break if y > top
      end

      # past log separator
      args.outputs.reserved << line(y: y + line_height_px.half, color: @text_color.mult_alpha(0.25 * slide_progress))

      y += line_height_px

      ((@archived_log.size - @log_offset) - 1).downto(0) do |idx|
        offset_after_write = write_primitive_and_return_offset args, left, y, @archived_log[idx], archived: true
        y += offset_after_write
        break if y > top
      end

      render_log_offset args

      args.outputs.reserved << { x: 10.from_right, y: slide_progress_bottom + 35,
                                 text: "Press CTRL+g or ESCAPE to clear the prompt.",
                                 anchor_y: 0,
                                 anchor_x: 1,
                                 r: 80,
                                 g: 80,
                                 b: 80,
                                 a: (255 * slide_progress).to_i }

      args.outputs.reserved << { x: 10.from_right, y: slide_progress_bottom + 60,
                                 text: "Press SHIFT+CTRL+r to hard reboot your game.",
                                 anchor_y: 0,
                                 anchor_x: 1,
                                 r: 80,
                                 g: 80,
                                 b: 80,
                                 a: (255 * slide_progress).to_i }

      args.outputs.reserved << { x: 10.from_right, y: slide_progress_bottom + 85,
                                 text: "Press CTRL+r to soft reset your game.",
                                 vertical_alignment_enum: 0,
                                 anchor_x: 1,
                                 r: 80,
                                 g: 80,
                                 b: 80,
                                 a: (255 * slide_progress).to_i }
    end

    def render_log_offset args
      return if @log_offset <= 0
      args.outputs.reserved << font_style.label(
        x: right.shift_left(5),
        y: top.shift_down(5 + line_height_px),
        text: "[#{@log_offset}/#{@log.size}]",
        color: @text_color,
        alignment_enum: 2
      )
    end

    def include_error_marker? text
      include_any_words?(text.gsub('OutputsDeprecated', ''), error_markers)
    end

    def error_markers
      ["exception:", "error:", "undefined method", "failed", "syntax error", "deprecated", "exception possibly", "exception thrown"]
    end

    def include_subdued_markers? text
      (text.start_with? "* INFO: ") && (include_any_words? text, subdued_markers)
    end

    def include_any_words? text, words
      words.any? { |w| text.downcase.include?(w) && !text.downcase.include?(":#{w}") }
    end

    def subdued_markers
      ["reloaded", "exported the", "~require~"]
    end

    def calc args
      if visible? &&
         @show_reason == :toast &&
         @toasted_at &&
         @toasted_at.elapsed?(@toast_duration, Kernel.global_tick_count)
        hide
      end

      if !$gtk.paused? && visible? && (show_reason == :exception || show_reason == :exception_on_load)
        hide
      end

      if $gtk.files_reloaded.length > 0
        clear_toast
        @toast_ids.clear
      end
    end

    def tick args
      begin
        if @disabled
          if console_toggle_key_down?(args)
            if !@disable_notification_shown
              args.gtk.notify! "Console is currently disabled (this message will not show up in a production build)."
              @disable_notification_shown = true
            end
          end
          return
        end
        render args
        process_inputs args
        return unless should_tick?
        calc args
        prompt.tick
        process_add_primitive_queue
        process_clear_logs_request_queue
        menu.tick args
      rescue Exception => e
        begin
          puts "#{e}"
          puts "* FATAL: The GTK::Console console threw an unhandled exception and has been reset. You should report this exception (along with reproduction steps) to DragonRuby."
          puts "#{e.__backtrace_to_org__}"
        rescue
        end
        @disabled = true
        $stdout.puts e
        $stdout.puts "* FATAL: The GTK::Console console threw an unhandled exception and has been reset. You should report this exception (along with reproduction steps) to DragonRuby."
      end
    end

    def process_clear_logs_request_queue
      if @clear_logs_request_queue.any? { |entry| entry.global_at <= Kernel.global_tick_count }
        @log.clear
        @archived_log.clear
        @clear_logs_request_queue.reject! { |entry| entry.global_at <= Kernel.global_tick_count }
      end
    end

    def process_add_primitive_queue
      @add_primitive_queue.find_all do |entry|
        entry.global_at <= Kernel.global_tick_count
      end.each do |entry|
        __add_primitive__ entry.primitive
      end

      @add_primitive_queue.reject! do |entry|
        entry.global_at <= Kernel.global_tick_count
      end
    end

    def set_command_with_history_silent command, histories, show_reason = nil
      set_command_extended command: command, histories: histories, show_reason: show_reason
    end

    def defaults_set_command_extended
      {
        command: "puts 'Hello World'",
        histories: [],
        show_reason: nil,
        force: false
      }
    end

    def set_command_extended opts
      opts = defaults_set_command_extended.merge opts
      (opts[:histories] || []).reverse.each do |h|
        @command_history.push_front h
      end

      if @command_set_at != Kernel.global_tick_count || opts[:force]
        self.current_input_str = opts[:command]
      elsif @command_history[0] != opts[:command]
        @command_history.push_front opts[:command]
      end

      @command_set_at = Kernel.global_tick_count
      @command_history_index = -1
      save_history
    end

    def set_command_with_history command, histories, show_reason = nil
      set_command_with_history_silent command, histories, show_reason
      show show_reason
    end

    def set_command command, show_reason = nil
      set_command_silent command, show_reason
      show show_reason
    end

    def set_command_silent command, show_reason = nil
      set_command_with_history_silent command, [], show_reason
    end

    def set_system_command command, show_reason = nil
      if $gtk.platform == "Mac OS X"
        set_command_silent "$gtk.system \"open #{command}\""
      else
        set_command_silent "$gtk.system \"start #{command}\""
      end
    end

    def system_command
      if $gtk.platform == "Mac OS X"
        "open"
      else
        "start"
      end
    end

    private

    def w
      Grid.w
    end

    def h
      Grid.h
    end

    def top
      Grid.top
    end

    def left
      Grid.left
    end

    def bottom
      Grid.bottom
    end

    def right
      Grid.right
    end

    def line_height_px
      font_style.line_height_px
    end

    def lines_on_one_page
      (h - 4).idiv(line_height_px)
    end

    def line(y:, color:)
      { x: left, y: y, x2: right, y2: y, **color.to_h }
    end

    def include_row_marker? log_entry
      log_entry[0] == "|"
    end

    def include_header_marker? log_entry
      return false if (log_entry.strip.include? ".rb")
      (log_entry.start_with? "* ")    ||
      (log_entry.start_with? "** ")   ||
      (log_entry.start_with? "*** ")  ||
      (log_entry.start_with? "**** ")
    end

    def include_header_1_marker? log_entry
      return false if (log_entry.strip.include? ".rb")
      (log_entry.start_with? "* ")
    end

    def include_header_2_marker? log_entry
      return false if (log_entry.strip.include? ".rb")
      (log_entry.start_with? "** ")
    end

    def include_header_3_marker? log_entry
      return false if (log_entry.strip.include? ".rb")
      (log_entry.start_with? "*** ")
    end

    def code? log_entry
      (just_symbol? log_entry) || (codeblock_marker? log_entry)
    end

    def just_symbol? log_entry
      scrubbed = log_entry.gsub("*", "").strip
      (scrubbed.start_with? ":") && (!scrubbed.include? " ") && (!scrubbed.include? "=>")
    end

    def code_comment? log_entry
      return true  if log_entry.strip.start_with?("# ")
      return false
    end

    def codeblock_marker? log_entry
      return true if log_entry.strip.start_with?("#+begin_src")
      return true if log_entry.strip.start_with?("#+end_src")
      return false
    end

    def color_for_plain_text log_entry
      log_entry = log_entry[4..-1] if log_entry.start_with? "!c!"

      if code? log_entry
        @code_color
      elsif code_comment? log_entry
        @comment_color
      elsif include_row_marker? log_entry
        @text_color
      elsif include_error_marker? log_entry
        @error_color
      elsif include_subdued_markers? log_entry
        @text_color.mult_alpha(0.5)
      elsif include_header_1_marker? log_entry
        @header_color
      elsif include_header_2_marker? log_entry
        @header_2_color
      elsif include_header_3_marker? log_entry
        @header_3_color
      elsif log_entry.start_with?("====")
        @header_color
      else
        @text_color
      end
    end

    def color_for_log_entry(log_entry)
      if log_entry.start_with?('!c!')  # loglevel color specified.
        return case log_entry[3..3].to_i
               when 0  # spam
                 @spam_color
               when 1  # debug
                 @debug_color
               #when 2  # info (caught by the `else` block.)
               #  @text_color
               when 3  # warn
                 @warn_color
               when 4  # error
                 @error_color
               when 5  # unfiltered
                 @unfiltered_color
               else
                 color_for_plain_text log_entry
               end
      end

      return color_for_plain_text log_entry
    end

    def prompt
      @prompt ||= Prompt.new(font_style: font_style, text_color: @text_color, console_text_width: console_text_width)
    end

    def current_input_str
      prompt.current_input_str
    end

    def current_input_str=(str)
      prompt.current_input_str = str
    end

    def clear
      @archived_log.clear
      @log.clear
      @prompt.clear
      :console_silent_eval
    end

    def slide_progress
      return 0 if !@toggled_at
      if visible?
        @slide_progress = Easing.smooth_stop start_at: @toggled_at, tick_count: Kernel.global_tick_count, duration: @animation_duration, power: 5
      else
        @slide_progress = Easing.smooth_stop start_at: @toggled_at, tick_count: Kernel.global_tick_count, duration: @animation_duration, power: 5, flip: true
      end
      @slide_progress
    end

    def clear_logs global_at: Kernel.global_tick_count
      @clear_logs_request_queue << { global_at: global_at }
    end
  end
end
