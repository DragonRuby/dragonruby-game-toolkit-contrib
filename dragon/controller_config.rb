# Copyright 2019 DragonRuby LLC
# MIT License
# controller_config.rb has been released under MIT (*only this file*).

# !!! FIXME: add console command to forget custom binding(s)
# !!! FIXME: add console command to forget replace existing binding(s)
# !!! FIXME: add console command go into play_around mode to make sure controller isn't wonky.

module GTK
  class ControllerConfig
    def initialize runtime
      @runtime = runtime
      @raw_joysticks = {}   # things that aren't game controllers to try to configure.
      @target = nil
      @animation_duration = (1.5).seconds
      @toggled_at = 0
      @fading = 0
      @current_part = 0
      @part_alpha = 0
      @part_alpha_increment = 10
      @joystick_state = {}
      @playing_around = false
      @used_bindings = {}
      @bindings = []
      @parts = [
        [ 919, 282, 'A button', 'a' ],
        [ 960, 323, 'B button', 'b' ],
        [ 878, 323, 'X button', 'x' ],
        [ 919, 365, 'Y button', 'y' ],
        [ 433, 246, 'left stick left', '-leftx' ],
        [ 497, 246, 'left stick right', '+leftx' ],
        [ 466, 283, 'left stick up', '-lefty' ],
        [ 466, 218, 'left stick down', '+lefty' ],
        [ 466, 246, 'left stick button', 'leftstick' ],
        [ 741, 246, 'right stick left', '-rightx' ],
        [ 802, 246, 'right stick right', '+rightx' ],
        [ 773, 283, 'right stick up', '-righty' ],
        [ 773, 218, 'right stick down', '+righty' ],
        [ 772, 246, 'right stick button', 'rightstick' ],
        [ 263, 465, 'left shoulder button', 'leftshoulder' ],
        [ 263, 503, 'left trigger', 'lefttrigger' ],
        [ 977, 465, 'right shoulder button', 'rightshoulder' ],
        [ 977, 503, 'right trigger', 'righttrigger' ],
        [ 318, 365, 'D-pad up', 'dpup' ],
        [ 360, 322, 'D-pad right', 'dpright' ],
        [ 318, 280, 'D-pad down', 'dpdown' ],
        [ 275, 322, 'D-pad left', 'dpleft' ],
        [ 570, 402, 'select/back button', 'back'],
        [ 619, 448, 'guide/home button', 'guide' ],
        [ 669, 402, 'start button', 'start' ],
      ]
    end

    def rawjoystick_connected jid, joystickname, guid
      return if jid < 0
      @raw_joysticks[jid] = { name: joystickname, guid: guid }
    end

    def rawjoystick_disconnected jid
      return if jid < 0
      if @raw_joysticks[jid] != nil
        @raw_joysticks.delete(jid)
        @runtime.ffi_misc.close_raw_joystick(jid)
        # Fade out the config screen if we were literally configuring this controller right now.
        if !@target.nil? && @target[0] == jid
          @target[0] = nil
          @toggled_at = Kernel.global_tick_count
          @fading = -1
        end
      end
    end

    def build_binding_string
      bindingstr = ''
      skip = false

      for i in 0..@parts.length-1
        if skip ; skip = false ; next ; end

        binding = @bindings[i]
        next if binding.nil?

        part = @parts[i][3]

        # clean up string:
        #  if axis uses -a0 for negative and +a0 for positive, just make it "leftx:a0" instead of "-leftx:-a0,+leftx:+a0"
        #  if axis uses +a0 for negative and -a0 for positive, just make it "leftx:a0~" instead of "-leftx:+a0,+leftx:-a0"
        if part == '-leftx' || part == '-lefty' || part == '-rightx' || part == '-righty'
          nextbinding = @bindings[i+1]
          if binding.start_with?('-a') && nextbinding.start_with?('+a') && binding[2..-1] == nextbinding[2..-1]
            skip = true
            part = part[1..-1]
            binding = binding[1..-1]
          elsif binding.start_with?('+a') && nextbinding.start_with?('-a') && binding[2..-1] == nextbinding[2..-1]
            skip = true
            part = part[1..-1]
            binding = "#{binding[1..-1]}~"
          end
        end

        bindingstr += "#{!bindingstr.empty? ? ',' : ''}#{part}:#{binding}"
      end

      details = @target[1]

      # !!! FIXME: no String.delete in mRuby?!?! Maybe so when upgrading.
      #name = details[:name].delete(',')
      # !!! FIXME: ...no regexp either...  :/
      #name = details[:name].gsub(/,/, ' ')  # !!! FIXME: will SDL let you escape these instead?
      unescaped = details[:name]
      name = ''
      for i in 0..unescaped.length-1
        ch = unescaped[i]
        name += (ch == ',') ? ' ' : ch
      end
      return "#{details[:guid]},#{name},platform:#{@runtime.platform},#{bindingstr}"
    end

    def move_to_different_part part
      if !@joystick_state[:axes].nil?
        @joystick_state[:axes].each { |i| i[:farthestval] = i[:startingval] if !i.nil? }
      end
      @current_part = part
    end

    def previous_part
      if @current_part > 0
        # remove the binding that we previously had here so it can be reused.
        bindstr = @bindings[@current_part - 1]
        @bindings[@current_part - 1] = nil
        @used_bindings[bindstr] = nil
        move_to_different_part @current_part - 1
      end
    end

    def next_part
      if @current_part < (@parts.length - 1)
        move_to_different_part @current_part + 1
      else
        @playing_around = true
      end
    end

    def set_binding bindstr
      return false if !@used_bindings[bindstr].nil?
      @used_bindings[bindstr] = @current_part
      @bindings[@current_part] = bindstr
      return true
    end

    # Called when a lowlevel joystick moves an axis.
    def rawjoystick_axis jid, axis, value
      return if @target.nil? || jid != @target[0] || @fading != 0 # skip if not currently considering this joystick.

      @joystick_state[:axes] ||= []
      @joystick_state[:axes][axis] ||= {
        moving: false,
        startingval: 0,
        currentval: 0,
        farthestval: 0
      }

      # this is the logic from SDL's controllermap.c, more or less, since this is hard to get right from scratch.
      state = @joystick_state[:axes][axis]
      state[:currentval] = value
      if !state[:moving]
        state[:moving] = true
        state[:startingval] = value
        state[:farthestval] = value
      end

      current_distance = (value - state[:startingval]).abs
      farthest_distance = (state[:farthestval] - state[:startingval]).abs
      if current_distance > farthest_distance
        state[:farthestval] = value
        farthest_distance = (state[:farthestval] - state[:startingval]).abs
      end

      # If we've gone out far enough and started to come back, let's bind this axis
      if (farthest_distance >= 16000) && (current_distance <= 10000)
        next_part if set_binding("#{(state[:farthestval] < 0) ? '-' : '+'}a#{axis}")
      end
    end

    # Called when a lowlevel joystick moves a hat.
    def rawjoystick_hat jid, hat, value
      return if @target.nil? || jid != @target[0] || @fading != 0 # skip if not currently considering this joystick.

      @joystick_state[:hats] ||= []
      @joystick_state[:hats][hat] = value

      return if value == 0   # 0 == centered, skip it
      next_part if set_binding("h#{hat}.#{value}")
    end

    # Called when a lowlevel joystick moves a button.
    def rawjoystick_button jid, button, pressed
      return if @target.nil? || jid != @target[0] || @fading != 0 # skip if not currently considering this joystick.

      @joystick_state[:buttons] ||= []
      @joystick_state[:buttons][button] = pressed

      return if !pressed
      next_part if set_binding("b#{button}")
    end

    def calc_fading
      if @fading == 0
        return 255
      elsif @fading > 0   # fading in
        percent = @toggled_at.global_ease(@animation_duration, :flip, :quint, :flip)
        if percent >= 1.0
          percent = 1.0
          @fading = 0
        end
      else  # fading out
        percent = @toggled_at.global_ease(@animation_duration, :flip, :quint)
        if percent <= 0.0
          percent = 0.0
          @fading = 0
        end
      end

      return (percent * 255.0).to_i
    end

    def render_basics args, msg, fade=255
      joystickname = @target[1][:name]
      args.outputs.primitives << [0, 0, GAME_WIDTH, GAME_HEIGHT, 255, 255, 255, fade].solid
      args.outputs.primitives << [0, 0, GAME_WIDTH, GAME_HEIGHT, 'dragonruby-controller.png', 0, fade, 255, 255, 255].sprite
      args.outputs.primitives << [GAME_WIDTH / 2, 700, joystickname, 2, 1, 0, 0, 0, fade].label
      args.outputs.primitives << [GAME_WIDTH / 2, 650, msg, 0, 1, 0, 0, 0, 255].label if !msg.empty?
    end

    def render_part_highlight args, part, alpha=255
      partsize = 41
      args.outputs.primitives << [part[0], part[1], partsize, partsize, 255, 0, 0, alpha].border
      args.outputs.primitives << [part[0]-1, part[1]-1, partsize+2, partsize+2, 255, 0, 0, alpha].border
      args.outputs.primitives << [part[0]-2, part[1]-2, partsize+4, partsize+4, 255, 0, 0, alpha].border
    end

    def choose_target
      if @target.nil?
        while !@raw_joysticks.empty?
          t = @raw_joysticks.shift  # see if there's a joystick waiting on us.
          next if t[0] < 0  # just in case.
          next if t[1][:guid].nil?  # did we already handle this guid? Dump it.
          @target = t
          break
        end
        return false if @target.nil?   # nothing to configure at the moment.
        @toggled_at = Kernel.global_tick_count
        @fading = 1
        @current_part = 0
        @part_alpha = 0
        @part_alpha_increment = 10
        @joystick_state = {}
        @used_bindings = {}
        @playing_around = false
        @bindings = []
      end
      return true
    end

    def render_part_highlight_from_bindstr args, bindstr, alpha=255
      partidx = @used_bindings[bindstr]
      return if partidx.nil?
      render_part_highlight args, @parts[partidx], alpha
    end

    def play_around args
      return false if !@playing_around

      if args.inputs.keyboard.key_down.escape
        @current_part = 0
        @part_alpha = 0
        @part_alpha_increment = 10
        @used_bindings = {}
        @playing_around = false
        @bindings = []
      elsif args.inputs.keyboard.key_down.space
        jid = @target[0]
        bindingstr = build_binding_string
        #puts("new controller binding: '#{bindingstr}'")
        @runtime.ffi_misc.add_controller_config bindingstr
        @runtime.ffi_misc.convert_rawjoystick_to_controller jid
        @target[0] = -1  # Conversion closes the raw joystick.

        # Handle any other pending joysticks that have the same GUID (so if you plug in four of the same model, we're already done!)
        guid = @target[1][:guid]
        @raw_joysticks.each { |jid, details|
          if details[:guid] == guid
            @runtime.ffi_misc.convert_rawjoystick_to_controller jid
            details[:guid] = nil
          end
        }

        # Done with this guy.
        @playing_around = false
        @toggled_at = Kernel.global_tick_count
        @fading = -1
        return false
      end

      render_basics args, 'Now play around with the controller, and make sure it feels right!'
      args.outputs.primitives << [GAME_WIDTH / 2, 90, '[ESCAPE]: Reconfigure, [SPACE]: Save this configuration', 0, 1, 0, 0, 0, 255].label

      axes = @joystick_state[:axes]
      if !axes.nil?
        for i in 0..axes.length-1
          next if axes[i].nil?
          value = axes[i][:currentval]
          next if value.nil? || (value.abs < 16000)
          render_part_highlight_from_bindstr args, "#{value < 0 ? '-' : '+'}a#{i}"
        end
      end

      hats = @joystick_state[:hats]
      if !hats.nil?
        for i in 0..hats.length-1
          value = hats[i]
          next if value.nil? || (value == 0)
          render_part_highlight_from_bindstr args, "h#{i}.#{value}"
        end
      end

      buttons = @joystick_state[:buttons]
      if !buttons.nil?
        for i in 0..buttons.length-1
          value = buttons[i]
          next if value.nil? || !value
          render_part_highlight_from_bindstr args, "b#{i}"
        end
      end

      return true
    end

    def should_tick?
      return true if @play_around
      return true if @target
      return false
    end

    def tick args
      return true if play_around args
      return false if !choose_target

      jid = @target[0]

      if @fading == 0
        # Cancel config?
        if args.inputs.keyboard.key_down.escape
          # !!! FIXME: prompt to ignore this joystick forever or just this run
          @toggled_at = Kernel.global_tick_count
          @fading = -1
        end
      end

      if @fading == 0
        if args.inputs.keyboard.key_down.backspace
          previous_part
        elsif args.inputs.keyboard.key_down.space
          next_part
        end
      end

      fade = calc_fading
      if (@fading < 0) && (fade == 0)
        @runtime.ffi_misc.close_raw_joystick(jid) if jid >= 0
        @target = nil   # done with this controller
        return false
      end

      render_basics args, (@fading >= 0) ? "We don't recognize this controller, so tell us about it!" : '', fade

      return true if fade < 255  # all done for now

      part = @parts[@current_part]
      args.outputs.primitives << [GAME_WIDTH / 2, 575, "Please press the #{part[2]}.", 0, 1, 0, 0, 0, 255].label
      render_part_highlight args, part, @part_alpha
      args.outputs.primitives << [GAME_WIDTH / 2, 90, '[ESCAPE]: Ignore controller, [BACKSPACE]: Go back one button, [SPACE]: Skip this button', 0, 1, 0, 0, 0, 255].label

      @part_alpha += @part_alpha_increment
      if (@part_alpha_increment > 0) && (@part_alpha >= 255)
        @part_alpha = 255
        @part_alpha_increment = -10
      elsif (@part_alpha_increment < 0) && (@part_alpha <= 0)
        @part_alpha = 0
        @part_alpha_increment = 10
      end

      return true
    end
  end
end
