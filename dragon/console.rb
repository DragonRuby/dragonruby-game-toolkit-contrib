# Copyright 2019 DragonRuby LLC
# MIT License
# console.rb has been released under MIT (*only this file*).

module GTK
  class Console
    class Color
      def initialize(color)
        @color = color
        @color << 255 if @color.size == 3
      end

      def mult_alpha(alpha_modifier)
        Color.new [@color[0], @color[1], @color[2], (@color[3].to_f * alpha_modifier).to_i]
      end

      # Support splat operator
      def to_a
        @color
      end

      def to_h
        { r: @color[0], g: @color[1], b: @color[2], a: @color[3] }
      end
    end

    class FontStyle
      attr_reader :font, :size_enum, :line_height

      def initialize(font:, size_enum:, line_height:)
        @font = font
        @size_enum = size_enum
        @line_height = line_height
      end

      def letter_size
        @letter_size ||= $gtk.calcstringbox 'W', size_enum, font
      end

      def line_height_px
        @line_height_px ||= letter_size.y * line_height
      end

      def label(x:, y:, text:, color:, alignment_enum: 0)
        {
          x: x,
          y: y.shift_up(line_height_px),  # !!! FIXME: remove .shift_up(line_height_px) when we fix coordinate origin on labels.
          text: text,
          font: font,
          size_enum: size_enum,
          alignment_enum: alignment_enum,
          **color.to_h,
        }.label
      end
    end

    attr_accessor :show_reason, :log, :prompt, :logo, :background_color,
                  :text_color, :cursor_color, :animation_duration,
                  :max_log_lines, :max_history, :current_input_str, :log,
                  :last_command_errored, :last_command, :error_color, :shown_at,
                  :header_color, :archived_log, :last_log_lines, :last_log_lines_count,
                  :suppress_left_arrow_behavior, :command_set_at,
                  :toast_ids,
                  :font_style

    def initialize
      @font_style = FontStyle.new(font: 'font.ttf', size_enum: 0, line_height: 1.1)
      @disabled = false
      @current_input_str = ''
      @log_offset = 0
      @visible = false
      @toast_ids = []
      @archived_log = []
      @log = [ 'Console ready.' ]
      @max_log_lines = 1000  # I guess...?
      @max_history = 1000  # I guess...?
      @command_history = []
      @command_history_index = -1
      @nonhistory_input = ''
      @prompt = '-> '
      @logo = 'console-logo.png'
      @history_fname = 'console_history.txt'
      @background_color = Color.new [0, 0, 0, 224]
      @text_color = Color.new [255, 255, 255]
      @error_color = Color.new [200, 50, 50]
      @header_color = Color.new [100, 200, 220]
      @cursor_color = Color.new [187, 21, 6]
      @animation_duration = 1.seconds
      @current_input_str = ''
      @shown_at = -1
      load_history
    end

    def console_text_width
      @console_text_width ||= (GAME_WIDTH - 20).idiv(font_style.letter_size.x)
    end

    def save_history
      $gtk.ffi_file.storefile(@history_fname, @command_history.reverse.join("\n"))
    end

    def load_history
      @command_history.clear
      str = $gtk.ffi_file.loadfile(@history_fname)
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
    end

    def enable
      @disabled = false
    end

    def addsprite obj
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

    def add_primitive obj
      if obj.is_a? Hash
        addsprite obj
      else
        addtext obj
      end
      nil
    end

    def addtext obj
      @last_log_lines_count ||= 1

      str = obj.to_s

      log_lines = []

      str.each_line do |s|
        s.wrapped_lines(self.console_text_width).each do |l|
          log_lines << l
        end
      end

      if log_lines == @last_log_lines
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
      @visible
    end

    def show reason = nil
      @shown_at = Kernel.global_tick_count
      @show_reason = reason
      toggle if hidden?
    end

    def hide
      if visible?
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
                            args.state.tick_count

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
      addtext "* toast :#{id}"
      puts "* TOAST: :#{id}"
      messages.each do |message|
        lines = message.to_s.wrapped_lines(self.console_text_width)
        dwim_duration += lines.length.seconds
        addtext "** #{message}"
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
        :backtick!,
        :tilde!,
        :superscript_two!,
        :section_sign!,
        :ordinal_indicator!,
        :circumflex!,
      ]
    end

    def console_toggle_key_down? args
      args.inputs.keyboard.key_down.any? console_toggle_keys
    end

    def eval_the_set_command
      cmd = @current_input_str.strip
      if cmd.length != 0
        @log_offset = 0
        @current_input_str = ''

        @command_history.pop while @command_history.length >= @max_history
        @command_history.unshift cmd
        @command_history_index = -1
        @nonhistory_input = ''

        if cmd == 'quit' || cmd == ':wq' || cmd == ':q!' || cmd == ':q' || cmd == ':wqa'
          $gtk.request_quit
        else
          puts "-> #{cmd}"
          begin
            @last_command = cmd
            Kernel.eval("$results = (#{cmd})")
            if $results.nil?
              puts "=> nil"
            else
              puts "=> #{$results}"
            end
            @last_command_errored = false
          rescue Exception => e
            @last_command_errored = true
            puts "#{e}"
            log "#{e}"
          end
        end
      end
    end

    def inputs_scroll_up_full? args
      return false if @disabled
      args.inputs.keyboard.key_down.pageup ||
        (args.inputs.keyboard.key_up.b && args.inputs.keyboard.key_up.control)
    end

    def scroll_up_full
      @log_offset += lines_on_one_page
      @log_offset = @log.size if @log_offset > @log.size
    end

    def inputs_scroll_up_half? args
      return false if @disabled
      args.inputs.keyboard.ctrl_u
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
      args.inputs.keyboard.ctrl_d
    end

    def inputs_clear_command? args
      return false if @disabled
      args.inputs.keyboard.escape || args.inputs.keyboard.ctrl_g
    end

    def scroll_down_half
      @log_offset -= lines_on_one_page.idiv(2)
      @log_offset = 0 if @log_offset < 0
    end

    def process_inputs args
      if console_toggle_key_down? args
        args.inputs.text.clear
        toggle
      end

      return unless visible?

      if !@suppress_left_arrow_behavior && args.inputs.keyboard.key_down.left && (@current_input_str || '').strip.length > 0
        log_info "Use repl.rb!", <<-S
The Console is nice for quick commands, but for more complex edits, use repl.rb.

I've written the current command at the top of a file called ./repl.rb (right next to dragonruby(.exe)). Please open the the file and apply additional edits there.
S
        if @last_command_written_to_repl_rb != @current_input_str
          @last_command_written_to_repl_rb = @current_input_str
          contents = $gtk.read_file 'app/repl.rb'
          contents ||= ''
          contents = <<-S + contents

# Remove the x from xrepl to run the command.
xrepl do
  #{@last_command_written_to_repl_rb}
end

S
          $gtk.suppress_hotload = true
          $gtk.write_file 'app/repl.rb', contents
          $gtk.reload_if_needed 'app/repl.rb', true
          $gtk.suppress_hotload = false
        end

        return
      end

      args.inputs.text.each { |str| @current_input_str << str }
      args.inputs.text.clear

      if args.inputs.keyboard.key_down.enter
        eval_the_set_command
      elsif args.inputs.keyboard.key_down.v
        if args.inputs.keyboard.key_down.control || args.inputs.keyboard.key_down.meta
          @current_input_str << $gtk.ffi_misc.getclipboard
        end
      elsif args.inputs.keyboard.key_down.up
        if @command_history_index == -1
          @nonhistory_input = @current_input_str
        end
        if @command_history_index < (@command_history.length - 1)
          @command_history_index += 1
          @current_input_str = @command_history[@command_history_index].clone
        end
      elsif args.inputs.keyboard.key_down.down
        if @command_history_index == 0
          @command_history_index = -1
          @current_input_str = @nonhistory_input
          @nonhistory_input = ''
        elsif @command_history_index > 0
          @command_history_index -= 1
          @current_input_str = @command_history[@command_history_index].clone
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
        @current_input_str.clear
        @command_history_index = -1
        @nonhistory_input = ''
      elsif args.inputs.keyboard.key_down.backspace || args.inputs.keyboard.key_down.delete
        @current_input_str.chop!
      end

      args.inputs.keyboard.key_down.clear
      args.inputs.keyboard.key_up.clear
      args.inputs.keyboard.key_held.clear
    end

    def write_primitive_and_return_offset(args, left, y, str, archived: false)
      if str.is_a?(Hash)
        padding = 10
        args.outputs.reserved << [left + 10, y - padding * 1.66, str[:w], str[:h], str[:path]].sprite
        return str[:h] + padding
      else
        write_line args, left, y, str, archived: archived
        return line_height_px
      end
    end

    def write_line(args, left, y, str, archived: false)
      color = color_for_log_entry(str)
      color = color.mult_alpha(0.5) if archived

      args.outputs.reserved << font_style.label(x: left.shift_right(10), y: y, text: str, color: color)
    end

    def render args
      return if !@toggled_at

      if visible?
        percent = @toggled_at.global_ease(@animation_duration, :flip, :quint, :flip)
      else
        percent = @toggled_at.global_ease(@animation_duration, :flip, :quint)
      end

      return if percent == 0

      bottom = top - (h * percent)
      args.outputs.reserved << [left, bottom, w, h, *@background_color.mult_alpha(percent)].solid
      args.outputs.reserved << [right.shift_left(210), bottom.shift_up(540), 200, 200, @logo, 0, (80.0 * percent).to_i].sprite

      y = bottom + 2  # just give us a little padding at the bottom.
      args.outputs.reserved << font_style.label(x: left.shift_right(10), y: y, text: "#{@prompt}#{@current_input_str}", color: @text_color)
      args.outputs.reserved << font_style.label(x: left.shift_right(8), y: y + 3, text: (" " * (prompt.length + @current_input_str.length)) + "|", color: @cursor_color)
      y += line_height_px * 1.5
      args.outputs.reserved << line(y: y, color: @text_color.mult_alpha(percent))
      y += line_height_px.to_f / 2.0

      ((@log.size - @log_offset) - 1).downto(0) do |idx|
        offset_after_write = write_primitive_and_return_offset args, left, y, @log[idx]
        y += offset_after_write
        break if y > top
      end

      # past log seperator
      args.outputs.reserved << line(y: y + line_height_px.half, color: @text_color.mult_alpha(0.25 * percent))

      y += line_height_px

      ((@archived_log.size - @log_offset) - 1).downto(0) do |idx|
        offset_after_write = write_primitive_and_return_offset args, left, y, @archived_log[idx], archived: true
        y += offset_after_write
        break if y > top
      end

      render_log_offset args
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
      ["exception", "error", "undefined method", "failed", "syntax", "deprecated"]
    end

    def include_subdued_markers? text
      include_any_words? text, subdued_markers
    end

    def include_any_words? text, words
      words.any? { |w| text.downcase.include?(w) && !text.downcase.include?(":#{w}") }
    end

    def subdued_markers
      ["reloaded", "exported the"]
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
        return if @disabled
        render args
        calc args
        process_inputs args
      rescue Exception => e
        @disabled = true
        $stdout.puts e
        $stdout.puts "* FATAL: The GTK::Console console threw an unhandled exception and has been reset. You should report this exception (along with reproduction steps) to DragonRuby."
      end
    end

    def set_command_with_history_silent command, histories, show_reason = nil
      @command_history.concat histories
      @command_history << command  if @command_history[-1] != command
      @current_input_str = command if @command_set_at != Kernel.global_tick_count
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

    private

    def w
      GAME_WIDTH
    end

    def h
      GAME_HEIGHT
    end

    # def top; def left; def right
    # Forward to grid
    %i[top left right].each do |method|
      define_method method do
        $gtk.args.grid.send(method)
      end
    end

    def line_height_px
      font_style.line_height_px
    end

    def lines_on_one_page
      (h - 4).idiv(line_height_px)
    end

    def line(y:, color:)
      [left, y, right, y, *color].line
    end

    def color_for_log_entry(log_entry)
      if include_error_marker? log_entry
        @error_color
      elsif include_subdued_markers? log_entry
        @text_color.mult_alpha(0.5)
      elsif log_entry.start_with?("====") || log_entry.include?("app") && !log_entry.include?("apple")
        @header_color
      else
        @text_color
      end
    end
  end
end
