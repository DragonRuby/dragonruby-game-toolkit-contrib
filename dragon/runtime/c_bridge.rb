# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# c_bridge.rb has been released under MIT (*only this file*).

module GTK
  class Runtime
    module CBridge
      def current_fps simulation_fps, rendering_fps
        @current_framerate_calc = simulation_fps
        @current_framerate_render = rendering_fps
      end

      def new_log_entry level, ticks, subsystem, str
        @console.add_text str, level
      end

      def untransform_mouse_x mousex
        @args.grid.untransform_x(mousex)
      end

      def untransform_mouse_y mousey
        @args.grid.untransform_y(mousey)
      end

      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def finger_down touchid, touchx, touchy, sender = false
        return if self.recording.is_replaying? && sender != :replay

        # FIXME: recording currently doesn't support fingers.
        self.record_input_history :finger_down, touchid, touchx, touchy

        touchx = untransform_mouse_x touchx
        touchy = untransform_mouse_y touchy

        touch_count_before = @args.inputs.touch.length

        if !@args.inputs.touch.has_key?(touchid)
          @args.inputs.touch[touchid] = FingerTouch.new
        end

        finger = @args.inputs.touch[touchid]
        finger.moved = true
        finger.down_at = Kernel.tick_count
        finger.moved_at = Kernel.tick_count
        finger.previous_x = touchx
        finger.previous_y = touchy
        finger.x = touchx
        finger.y = touchy
        finger.touch_order = self.increase_touch_count
        finger.global_down_at = Kernel.global_tick_count
        finger.global_moved_at = Kernel.global_tick_count

        if finger.touch_order == 0
          @args.inputs.finger_one = finger
        elsif finger.touch_order == 1
          @args.inputs.finger_two = finger
        end

        if touchx < Grid.w / 2
          @args.inputs.finger_left = { x: touchx, y: touchy, w: 1, h: 1 }
        elsif touchx > Grid.w / 2
          @args.inputs.finger_right = { x: touchx, y: touchy, w: 1, h: 1 }
        end

        if @args.inputs.last_active != :mouse
          @args.inputs.last_active_at = Kernel.tick_count
          @args.inputs.last_active_global_at = Kernel.global_tick_count
        end
        @args.inputs.last_active = :mouse

        __simulate_mouse_move_for_touches__(touch_count_before)

        if @args.inputs.touch.length == 1
          mouse_button_pressed 1
        elsif @args.inputs.touch.length == 2
          @args.inputs.pinch_zoom = 0
        end
      end

      def __simulate_mouse_move_for_touches__(touch_count_before)
        # get touch points to compute the point that is equadistant from all touch points
        touch_points = @args.inputs.touch.map { |_, touch| { x: touch.x, y: touch.y } }

        # compute the center of all touch points
        center = touch_points.reduce({ x: 0, y: 0 }) do |acc, touch|
          acc.x += touch.x
          acc.y += touch.y
          acc
        end

        center.x /= touch_points.count
        center.y /= touch_points.count

        # simulate mouse move
        transform_x = @args.grid.transform_x(center.x)
        transform_y = @args.grid.transform_y(center.y)

        if @args.inputs.touch.length == 1
          if touch_count_before == 0
            @args.inputs.touch_center.x = transform_x
            @args.inputs.touch_center.y = transform_y
          else
            @args.inputs.touch_center.x = @args.inputs.touch_center.x.lerp(transform_x, 0.1)
            @args.inputs.touch_center.y = @args.inputs.touch_center.y.lerp(transform_y, 0.1)
          end
        else
          @args.inputs.touch_center.x = @args.inputs.touch_center.x.lerp(transform_x, 0.1)
          @args.inputs.touch_center.y = @args.inputs.touch_center.y.lerp(transform_y, 0.1)
        end

        mouse_move @args.inputs.touch_center.x, @args.inputs.touch_center.y
      end


      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def finger_move touchid, touchx, touchy, sender = false
        return if self.recording.is_replaying? && sender != :replay

        # FIXME: recording currently doesn't support fingers.
        self.record_input_history :finger_move, touchid, touchx, touchy

        # If the touch is missing, we ignore it here.
        return if !@args.inputs.touch.has_key?(touchid)

        touchx = untransform_mouse_x touchx
        touchy = untransform_mouse_y touchy

        finger = @args.inputs.touch[touchid]
        finger.moved = true
        finger.moved_at = Kernel.tick_count

        finger.previous_x ||= touchx
        finger.previous_x ||= touchy
        finger.x ||= finger.x
        finger.y ||= finger.y

        finger.previous_x = finger.x
        finger.previous_y = finger.y

        finger.x = touchx
        finger.y = touchy
        finger.global_moved_at = Kernel.global_tick_count

        if finger.touch_order == 0
          @args.inputs.finger_one = finger
        elsif finger.touch_order == 1
          @args.inputs.finger_two = finger
        end

        if touchx < Grid.w / 2
          @args.inputs.finger_left = { x: touchx, y: touchy, w: 1, h: 1 }
        elsif touchx > Grid.w / 2
          @args.inputs.finger_right = { x: touchx, y: touchy, w: 1, h: 1 }
        end

        if @args.inputs.last_active != :mouse
          @args.inputs.last_active_at = Kernel.tick_count
          @args.inputs.last_active_global_at = Kernel.global_tick_count
        end

        @args.inputs.last_active = :mouse

        if @args.inputs.touch.length == 2
          first_touch = @args.inputs.touch.values.first
          second_touch = @args.inputs.touch.values.last

          previous_distance = Geometry.distance({ x: first_touch.previous_x, y: first_touch.previous_y },
                                                { x: second_touch.previous_x, y: second_touch.previous_y })

          current_distance = Geometry.distance({ x: first_touch.x, y: first_touch.y },
                                               { x: second_touch.x, y: second_touch.y })

          @args.inputs.pinch_zoom = previous_distance - current_distance
          mouse_wheel 0, @args.inputs.pinch_zoom.fdiv(__mouse_wheel_to_pinch_zoom_ratio__), false
        else
          @args.inputs.pinch_zoom = 0
        end

        __simulate_mouse_move_for_touches__(@args.inputs.touch.length)
      end

      def __mouse_wheel_to_pinch_zoom_ratio__
        25
      end

      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def finger_up touchid, sender = false
        return if self.recording.is_replaying? && sender != :replay

        # FIXME: recording currently doesn't support fingers.
        self.record_input_history :finger_up, touchid, 0, 0

        if @args.inputs.touch[touchid] && @args.inputs.touch[touchid].x < Grid.w / 2
          @args.inputs.finger_left = nil
        elsif @args.inputs.touch[touchid] && @args.inputs.touch[touchid].x > Grid.w / 2
          @args.inputs.finger_right = nil
        end

        if @args.inputs.touch.has_key?(touchid)
          touch_order = @args.inputs.touch[touchid].touch_order
          @args.inputs.touch.delete(touchid)
          if touch_order == 0
            @args.inputs.finger_one = nil
          elsif touch_order == 1
            @args.inputs.finger_two = nil
          end
        end

        if !@args.inputs.touch.any?
          self.reset_touch_count
          # just in case something got confused.
          @args.inputs.finger_one = nil
          @args.inputs.finger_two = nil
          @args.inputs.finger_left = nil
          @args.inputs.finger_right = nil
        end

        if @args.inputs.last_active != :mouse
          @args.inputs.last_active_at = Kernel.tick_count
          @args.inputs.last_active_global_at = Kernel.global_tick_count
        end
        @args.inputs.last_active = :mouse

        if @args.inputs.touch.length == 0
          mouse_button_up 1
        end

        if @args.inputs.touch.length != 0
          # property is used to delay the mouse position changes for touch events
          # eg, if they are pinching/zooming, we don't want to change the mouse position
          # immediately if they aren't precise with their finger lifts.
          @args.inputs.multi_touch_finger_up_at = Kernel.tick_count
        end

        @args.inputs.pinch_zoom = 0
      end

      # FIXME: add support for replays with mouse_move_relative
      def mouse_move_relative mousex, mousey, relative_x, relative_y, sender = false
        return if self.recording.is_replaying? && sender != :replay
        relative_y = -relative_y  # Y coordinate goes up, unlike SDL.
        # FIXME: replay recording will not work in mouse game mode
        self.record_input_history :mouse_move, mousex, mousey, 2
        mousex = untransform_mouse_x mousex
        mousey = untransform_mouse_y mousey

        __mouse_move_relative_with_untransformed_points_ mousex, mousey, relative_x, relative_y, sender
      end

      def __mouse_move_relative_with_untransformed_points_ mousex, mousey, relative_x, relative_y, sender = false
        @args.inputs.mouse.active = Kernel.tick_count
        @args.inputs.mouse.moved = MousePoint.new mousex, mousey
        @args.inputs.mouse.previous_x = @args.inputs.mouse.x
        @args.inputs.mouse.previous_y = @args.inputs.mouse.y
        @args.inputs.mouse.x = mousex
        @args.inputs.mouse.y = mousey

        # !!! FIXME: double-check if we _need_ to calculate this ourselves...?
        if self.mouse_grab == 2  # if we're in SDL relative mouse mode ("scroll forever mode"), then use SDL's values, even in HD mode.
          @args.inputs.mouse.relative_x = relative_x
          @args.inputs.mouse.relative_y = relative_y
        else   # calculate this ourselves, as we might have scaled this for HD mode.
          @args.inputs.mouse.relative_x = mousex - @args.inputs.mouse.previous_x
          @args.inputs.mouse.relative_y = mousey - @args.inputs.mouse.previous_y
        end

        @args.inputs.mouse.moved_at = Kernel.tick_count
        @args.inputs.mouse.global_moved_at = Kernel.global_tick_count

        if @args.inputs.last_active != :mouse
          @args.inputs.last_active_at = Kernel.tick_count
          @args.inputs.last_active_global_at = Kernel.global_tick_count
        end
        @args.inputs.last_active = :mouse

        # simulation of touch when using mouse
        if !GTK.platform?(:touch)
          if @args.inputs.finger_left
            @args.inputs.finger_left.x = mousex
            @args.inputs.finger_left.y = mousey
          end

          if @args.inputs.finger_right
            @args.inputs.finger_right.x = mousex
            @args.inputs.finger_right.y = mousey
          end
        end

        @args.inputs.mouse.buttons.each do |button|
          button.x = @args.inputs.mouse.x
          button.y = @args.inputs.mouse.y
          button.relative_x = @args.inputs.mouse.relative_x
          button.relative_y = @args.inputs.mouse.relative_y
        end
      end

      # WARNING: need to keep this method signature the same for replay backwards compatibility
      def mouse_move mousex, mousey, sender = false
        mouse_move_relative mousex, mousey, 0, 0, sender
      end

      def simulate_mouse_clicks positions
        running_tick_count = Kernel.tick_count + 1
        positions.each do |position|
          $gtk.scheduled_callbacks[running_tick_count] = lambda {
            @args.inputs.mouse.x = position.x
            @args.inputs.mouse.y = position.y
            mouse_button_pressed 1
          }
          running_tick_count += 7
          $gtk.scheduled_callbacks[running_tick_count] = lambda {
            @args.inputs.mouse.x = position.x
            @args.inputs.mouse.y = position.y
            mouse_button_up 1
          }
          running_tick_count += 30
        end
      end

      def update_mouse_buttons newbuttons
        @args.inputs.mouse.active = Kernel.tick_count
        @args.inputs.mouse.button_bits = newbuttons
        @args.inputs.mouse.button_left = (newbuttons & (1 << 0)) != 0
        @args.inputs.mouse.button_middle = (newbuttons & (1 << 1)) != 0
        @args.inputs.mouse.button_right = (newbuttons & (1 << 2)) != 0
        @args.inputs.mouse.button_x1 = (newbuttons & (1 << 3)) != 0
        @args.inputs.mouse.button_x2 = (newbuttons & (1 << 4)) != 0

        if @args.inputs.last_active != :mouse
          @args.inputs.last_active_at = Kernel.tick_count
          @args.inputs.last_active_global_at = Kernel.global_tick_count
        end

        @args.inputs.last_active = :mouse
      end

      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def mouse_button_pressed button, sender = false
        return if self.recording.is_replaying? && sender != :replay

        self.record_input_history :mouse_button_pressed, button, 0, 1
        update_mouse_buttons @args.inputs.mouse.button_bits | (1 << (button-1))


        @args.inputs.mouse.active = Kernel.tick_count
        mousex = @args.inputs.mouse.x
        mousey = @args.inputs.mouse.y

        @args.inputs.mouse.click = MousePoint.new mousex, mousey
        @args.inputs.mouse.click_at = Kernel.tick_count
        @args.inputs.mouse.global_click_at = Kernel.global_tick_count

        if @args.inputs.last_active != :mouse
          @args.inputs.last_active_at = Kernel.tick_count
          @args.inputs.last_active_global_at = Kernel.global_tick_count
        end

        @args.inputs.last_active = :mouse

        # simulation of touch when using mouse
        if button == 1 && !GTK.platform?(:touch)
          if mousex < Grid.w / 2
            @args.inputs.finger_left = { x: mousex, y: mousey, w: 1, h: 1 }
            @args.inputs.finger_right = nil
          elsif mousex > Grid.w / 2
            @args.inputs.finger_left = nil
            @args.inputs.finger_right = { x: mousex, y: mousey, w: 1, h: 1 }
          end
        end

        case button
        when 1
          @args.inputs.mouse.buttons.left.click = MousePoint.new mousex, mousey
          @args.inputs.mouse.buttons.left.click_at = Kernel.tick_count
          @args.inputs.mouse.buttons.left.global_click_at = Kernel.global_tick_count
        when 2
          @args.inputs.mouse.buttons.middle.click = MousePoint.new mousex, mousey
          @args.inputs.mouse.buttons.middle.click_at = Kernel.tick_count
          @args.inputs.mouse.buttons.middle.global_click_at = Kernel.global_tick_count
        when 3
          @args.inputs.mouse.buttons.right.click = MousePoint.new mousex, mousey
          @args.inputs.mouse.buttons.right.click_at = Kernel.tick_count
          @args.inputs.mouse.buttons.right.global_click_at = Kernel.global_tick_count
        when 4
          @args.inputs.mouse.buttons.x1.click = MousePoint.new mousex, mousey
          @args.inputs.mouse.buttons.x1.click_at = Kernel.tick_count
          @args.inputs.mouse.buttons.x1.global_click_at = Kernel.global_tick_count
        when 5
          @args.inputs.mouse.buttons.x2.click = MousePoint.new mousex, mousey
          @args.inputs.mouse.buttons.x2.click_at = Kernel.tick_count
          @args.inputs.mouse.buttons.x2.global_click_at = Kernel.global_tick_count
        end
      end

      # this is for legacy recordings; this is ignored for new code, since it doesn't handle multi-buttons.
      def mouse_pressed mousex, mousey, sender = false
        # self.record_input_history :mouse_pressed, mousex, mousey, 2
        @args.inputs.mouse.active = Kernel.tick_count
        mouse_button_pressed 1, sender
        if @args.inputs.last_active != :mouse
          @args.inputs.last_active_at = Kernel.tick_count
          @args.inputs.last_active_global_at = Kernel.global_tick_count
        end
        @args.inputs.last_active = :mouse
      end

      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def mouse_button_up button, sender = false
        return if self.recording.is_replaying? && sender != :replay

        @args.inputs.mouse.active = Kernel.tick_count
        self.record_input_history :mouse_button_up, button, 0, 1
        update_mouse_buttons @args.inputs.mouse.button_bits & ~(1 << (button-1))

        mousex = @args.inputs.mouse.x
        mousey = @args.inputs.mouse.y

        @args.inputs.mouse.up = MousePoint.new mousex, mousey
        @args.inputs.mouse.up_at = Kernel.tick_count
        @args.inputs.mouse.global_up_at = Kernel.global_tick_count

        if @args.inputs.last_active != :mouse
          @args.inputs.last_active_at = Kernel.tick_count
          @args.inputs.last_active_global_at = Kernel.global_tick_count
        end

        @args.inputs.last_active = :mouse

        # simulation of touch when using mouse
        if button == 1 && !GTK.platform?(:touch)
          @args.inputs.finger_left = nil
          @args.inputs.finger_right = nil
        end

        case button
        when 1
          @args.inputs.mouse.buttons.left.up = MousePoint.new mousex, mousey
          @args.inputs.mouse.buttons.left.up_at = Kernel.tick_count
          @args.inputs.mouse.buttons.left.global_up_at = Kernel.global_tick_count
        when 2
          @args.inputs.mouse.buttons.middle.up = MousePoint.new mousex, mousey
          @args.inputs.mouse.buttons.middle.up_at = Kernel.tick_count
          @args.inputs.mouse.buttons.middle.global_up_at = Kernel.global_tick_count
        when 3
          @args.inputs.mouse.buttons.right.up = MousePoint.new mousex, mousey
          @args.inputs.mouse.buttons.right.up_at = Kernel.tick_count
          @args.inputs.mouse.buttons.right.global_up_at = Kernel.global_tick_count
        when 4
          @args.inputs.mouse.buttons.x1.up = MousePoint.new mousex, mousey
          @args.inputs.mouse.buttons.x1.up_at = Kernel.tick_count
          @args.inputs.mouse.buttons.x1.global_up_at = Kernel.global_tick_count
        when 5
          @args.inputs.mouse.buttons.x2.up = MousePoint.new mousex, mousey
          @args.inputs.mouse.buttons.x2.up_at = Kernel.tick_count
          @args.inputs.mouse.buttons.x2.global_up_at = Kernel.global_tick_count
        end
      end

      # this is for legacy recordings; this is ignored for new code, since it doesn't handle multi-buttons.
      def mouse_up mousex, mousey, sender = false
        #self.record_input_history :mouse_up, mousex, mousey, 2
        @args.inputs.mouse.active = Kernel.tick_count
        mouse_button_up 1, sender
        if @args.inputs.last_active != :mouse
          @args.inputs.last_active_at = Kernel.tick_count
          @args.inputs.last_active_global_at = Kernel.global_tick_count
        end
        @args.inputs.last_active = :mouse
      end

      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def mouse_wheel x, y = 0, inverted = false, sender = false
        return if self.recording.is_replaying? && sender != :replay

        @args.inputs.mouse.active = Kernel.tick_count

        record_y = y
        record_y *= -1 if inverted
        self.record_input_history_3_params :mouse_wheel, x, y, inverted

        wheel = @args.inputs.mouse.wheel
        if wheel.nil?
          wheel = { x: x, y: y, inverted: inverted,
                    created_at: Kernel.tick_count,
                    global_created_at: Kernel.global_tick_count }
          @args.inputs.mouse.wheel = wheel
        else
          wheel.x += x
          wheel.y += y
        end

        wheel.created_at = Kernel.tick_count
        wheel.created_at_time = Kernel.global_tick_count

        if @args.inputs.last_active != :mouse
          @args.inputs.last_active_at = Kernel.tick_count
          @args.inputs.last_active_global_at = Kernel.global_tick_count
        end

        @args.inputs.last_active = :mouse

        # simulate pinch_zoom
        if !GTK.platform?(:touch)
          @args.inputs.pinch_zoom = wheel.y * __mouse_wheel_to_pinch_zoom_ratio__
        end
      end

      def textinput str, sender = false
        return if self.recording.is_replaying? && sender != :replay
        self.record_input_history :textinput, str, 0, 1
        @args.inputs.text << str
      end

      def key_down_in_game raw_key, modifier
        @args.inputs.keyboard.key_down.keycodes[raw_key] = Kernel.tick_count
        names = KeyboardKeys.sdl_to_key raw_key, modifier
        return unless names

        if !KeyboardKeys.sdl_modifier_key? raw_key
          if @args.inputs.keyboard.shift
            unshifted_keys = names.map do |name|
              KeyboardKeys.shift_char_to_char_hash[name]
            end
            names += unshifted_keys
          end
        end

        keys_currently_held = @args.inputs.keyboard.key_held.truthy_keys
        keys_to_set = names - keys_currently_held
        keys_to_set.uniq!
        @args.inputs.keyboard.active = Kernel.tick_count
        @args.inputs.keyboard.key_down.char    = KeyboardKeys.char_with_shift(raw_key, modifier)
        @args.inputs.keyboard.key_down.raw_key = raw_key
        @args.inputs.keyboard.key_down.set keys_to_set, Kernel.tick_count
        if @args.inputs.last_active != :keyboard
          @args.inputs.last_active_at = Kernel.tick_count
          @args.inputs.last_active_global_at = Kernel.global_tick_count
        end
        @args.inputs.last_active = :keyboard
      end

      def key_up_in_game raw_key, modifier, sender = false
        @args.inputs.keyboard.key_up.keycodes[raw_key] = Kernel.tick_count
        names = KeyboardKeys.sdl_to_key raw_key, modifier
        names.uniq! if names
        return unless names
        if KeyboardKeys.sdl_modifier_key? raw_key
          if KeyboardKeys.sdl_shift_key? raw_key
            currently_held_keys = @args.inputs.keyboard.key_held.truthy_keys
            shifted_keys = currently_held_keys.map do |key|
              KeyboardKeys.char_to_shift_char_hash[key]
            end
            names += shifted_keys
          end
        else
          currently_held_keys = @args.inputs.keyboard.key_held.truthy_keys
          unshifted_keys = currently_held_keys.map do |key|
            KeyboardKeys.shift_char_to_char_hash[key]
          end
          names += unshifted_keys
          names -= KeyboardKeys.sdl_modifier_key_methods modifier
        end
        @args.inputs.keyboard.active = Kernel.tick_count
        @args.inputs.keyboard.key_up.char    = KeyboardKeys.char_with_shift(raw_key, modifier)
        @args.inputs.keyboard.key_up.raw_key = raw_key
        @args.inputs.keyboard.key_up.set names, Kernel.tick_count
        if @args.inputs.last_active != :keyboard
          @args.inputs.last_active_at = Kernel.tick_count
          @args.inputs.last_active_global_at = Kernel.global_tick_count
        end
        @args.inputs.last_active = :keyboard
      end

      def scancode_down_raw raw_scancode, modifier, sender = false
        return if @slowmo_factor_debounce
        self.record_input_history :scancode_down_raw, raw_scancode, modifier, 2, true
        scancode_method = KeyboardKeys.scancode_to_method_hash[raw_scancode]
        if scancode_method
          currently_held_scancode = @args.inputs.keyboard.key_held.send(scancode_method)
          if !currently_held_scancode
            @args.inputs.keyboard.key_down.send("#{scancode_method}=", Kernel.tick_count)
          end
        end
      end

      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def key_down_raw raw_key, modifier, sender = false
        return if @slowmo_factor_debounce
        if self.recording.is_replaying? && sender != :replay
          char = KeyboardKeys.char_with_shift raw_key, modifier
          first_name = KeyboardKeys.char_to_method(char, raw_key).first
          first_name = "#{first_name}!".to_sym if first_name

          if @console.console_toggle_keys.include?(first_name) || (char == "r" && modifier == 64)
            self.recording.stop_replay
          else
            return
          end
        end
        self.record_input_history :key_down_raw, raw_key, modifier, 2, true
        key_down_in_game raw_key.to_i, modifier
      end

      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def key_up_raw raw_key, modifier, sender = false
        return if self.recording.is_replaying? && sender != :replay
        self.record_input_history :key_up_raw, raw_key, modifier, 2
        key_up_in_game raw_key.to_i, modifier
      end

      def scancode_up_raw raw_scancode, modifier, sender = false
        return if self.recording.is_replaying? && sender != :replay
        self.record_input_history :scancode_up_raw, raw_scancode, modifier, 2
        scancode_method = KeyboardKeys.scancode_to_method_hash[raw_scancode]
        if scancode_method
          @args.inputs.keyboard.key_up.send "#{scancode_method}=", Kernel.tick_count
        end
      end

      RAW_CONTROLLER_KEY_LOOKUP = {
        1   => :up,
        2   => :down,
        3   => :left,
        4   => :right,
        13  => :start,
        14  => :b,
        15  => :a,
        16  => :x,
        17  => :y,
        18  => :l1,
        19  => :r1,
        20  => :l3,
        21  => :r3,
        22  => :l2,
        23  => :r2,
        24  => :directional_up,
        25  => :directional_down,
        26  => :directional_left,
        27  => :directional_right,
        28  => :select,
        29  => :home
      }.freeze

      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def controller_key_event player_num, raw_key, event, sender = false
        return if self.recording.is_replaying? && sender != :replay
        num_as_word = player_num ? :one : :two
        self.record_input_history :"#{event}_player_#{num_as_word}", raw_key, 0, 1

        label = RAW_CONTROLLER_KEY_LOOKUP.fetch(raw_key.to_i)
        controller = @args.inputs.controllers[player_num - 1]

        controller.active = Kernel.tick_count
        case event
        when :key_down
          controller.activate_down(label)
        when :key_held
          controller.activate_held(label)
        when :key_up
          controller.activate_up(label)
        else
          raise <<-S
  * ERROR:
  Layout#set_key failed for player_num: #{player_num}, raw_key: #{raw_key}, event: #{event}.

  S
        end

        if @args.inputs.last_active != :controller
          @args.inputs.last_active_at = Kernel.tick_count
          @args.inputs.last_active_global_at = Kernel.global_tick_count
        end
        @args.inputs.last_active = :controller
      end

      def controller_key_down player_num, raw_key, sender = false
        controller_key_event(player_num, raw_key, :key_down, sender)
      end

      def controller_key_held player_num, raw_key, sender = false
        controller_key_event(player_num, raw_key, :key_held, sender)
      end

      def controller_key_up player_num, raw_key, sender = false
        controller_key_event(player_num, raw_key, :key_up, sender)
      end

      def window_keyboard_focus_changed gained
        @args.inputs.keyboard.has_focus = gained
      end

      def window_mouse_focus_changed gained
        @args.inputs.mouse.has_focus = gained
      end

      def analog_to_perc value
        (value.fdiv 32767).round(2)
      end

      # =============================================
      # PLAYER 1
      # =============================================
      def controller_one_connected name
        @args.inputs.controller_one.connected = true
        @args.inputs.controller_one.name = name
      end

      def reset_controller_last_active_if_needed
        if @args.inputs.last_active == :controller
          if platform?(:mobile)
            @args.inputs.last_active = :mouse
            @args.inputs.last_active_at = Kernel.tick_count
          else
            @args.inputs.last_active = :keyboard
            @args.inputs.last_active_at = Kernel.tick_count
          end
        end
      end

      def controller_one_disconnected
        @args.inputs.controller_one.connected = false
        reset_controller_last_active_if_needed
      end

      def key_down_player_one raw_key, sender = false
        controller_key_down(1, raw_key, sender)
      end

      def key_held_player_one raw_key, sender = false
        controller_key_held(1, raw_key, sender)
      end

      def key_up_player_one raw_key, sender = false
        controller_key_up(1, raw_key, sender)
      end

      def __controller_analog_set_last_active_if_needed__ target_controller, raw_analog_value
        return if raw_analog_value.abs <= analog_dead_zone

        if !target_controller.active
          target_controller.active = true
          target_controller.active_at = Kernel.tick_count
          target_controller.active_global_at = Kernel.global_tick_count
        end

        if @args.inputs.last_active != :controller
          @args.inputs.last_active_at = Kernel.tick_count
          @args.inputs.last_active_global_at = Kernel.global_tick_count
          @args.inputs.last_active = :controller
        end
      end

      def analog_dead_zone
        3200
      end

      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def left_analog_x_player_1 value, sender = false
        return if self.recording.is_replaying? && sender != :replay
        return if @previous_left_analog_x_player_1 == value
        @previous_left_analog_x_player_1 = value
        self.record_input_history :left_analog_x_player_1, value, 0, 1
        __controller_analog_set_last_active_if_needed__ @args.inputs.controller_one, value
        value = 0 if value.abs <= analog_dead_zone
        @args.inputs.controller_one.left_analog_x_raw = value
        @args.inputs.controller_one.left_analog_x_perc = analog_to_perc value
      end

      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def left_analog_y_player_1 value, sender = false
        return if self.recording.is_replaying? && sender != :replay
        return if @previous_left_analog_y_player_1 == value
        @previous_left_analog_y_player_1 = value
        self.record_input_history :left_analog_y_player_1, value, 0, 1
        __controller_analog_set_last_active_if_needed__ @args.inputs.controller_one, value
        value = 0 if value.abs <= analog_dead_zone
        @args.inputs.controller_one.left_analog_y_raw = value.*(-1)
        @args.inputs.controller_one.left_analog_y_perc = analog_to_perc value.*(-1)
      end

      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def right_analog_x_player_1 value, sender = false
        return if self.recording.is_replaying? && sender != :replay
        return if @previous_right_analog_x_player_1 == value
        @previous_right_analog_x_player_1 = value
        self.record_input_history :right_analog_x_player_1, value, 0, 1
        __controller_analog_set_last_active_if_needed__ @args.inputs.controller_one, value
        value = 0 if value.abs <= analog_dead_zone
        @args.inputs.controller_one.right_analog_x_raw = value
        @args.inputs.controller_one.right_analog_x_perc = analog_to_perc value
      end

      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def right_analog_y_player_1 value, sender = false
        return if self.recording.is_replaying? && sender != :replay
        return if @previous_right_analog_y_player_1 == value
        @previous_right_analog_y_player_1 = value
        self.record_input_history :right_analog_y_player_1, value, 0, 1
        __controller_analog_set_last_active_if_needed__ @args.inputs.controller_one, value
        value = 0 if value.abs <= analog_dead_zone
        @args.inputs.controller_one.right_analog_y_raw = value.*(-1)
        @args.inputs.controller_one.right_analog_y_perc = analog_to_perc value.*(-1)
      end

      # =============================================
      # PLAYER 2
      # =============================================
      def controller_two_connected name
        @args.inputs.controller_two.connected = true
        @args.inputs.controller_two.name = name
      end

      def controller_two_disconnected
        @args.inputs.controller_two.connected = false
        reset_controller_last_active_if_needed
      end

      def key_down_player_two raw_key, sender = false
        controller_key_down(2, raw_key, sender)
      end

      def key_held_player_two raw_key, sender = false
        controller_key_held(2, raw_key, sender)
      end

      def key_up_player_two raw_key, sender = false
        controller_key_up(2, raw_key, sender)
      end

      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def left_analog_x_player_2 value, sender = false
        return if self.recording.is_replaying? && sender != :replay
        return if @previous_left_analog_x_player_2 == value
        @previous_left_analog_x_player_2 = value
        self.record_input_history :left_analog_x_player_2, value, 0, 1
        __controller_analog_set_last_active_if_needed__ @args.inputs.controller_two, value
        value = 0 if value.abs <= analog_dead_zone
        @args.inputs.controller_two.left_analog_x_raw = value
        @args.inputs.controller_two.left_analog_x_perc = analog_to_perc value
      end

      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def left_analog_y_player_2 value, sender = false
        return if self.recording.is_replaying? && sender != :replay
        return if @previous_left_analog_y_player_2 == value
        @previous_left_analog_y_player_2 = value
        self.record_input_history :left_analog_y_player_2, value, 0, 1
        __controller_analog_set_last_active_if_needed__ @args.inputs.controller_two, value
        value = 0 if value.abs <= analog_dead_zone
        @args.inputs.controller_two.left_analog_y_raw = value.*(-1)
        @args.inputs.controller_two.left_analog_y_perc = analog_to_perc value.*(-1)
      end

      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def right_analog_x_player_2 value, sender = false
        return if self.recording.is_replaying? && sender != :replay
        return if @previous_right_analog_x_player_2 == value
        @previous_right_analog_x_player_2 = value
        self.record_input_history :right_analog_x_player_2, value, 0, 1
        __controller_analog_set_last_active_if_needed__ @args.inputs.controller_two, value
        value = 0 if value.abs <= analog_dead_zone
        @args.inputs.controller_two.right_analog_x_raw = value
        @args.inputs.controller_two.right_analog_x_perc = analog_to_perc value
      end

      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def right_analog_y_player_2 value, sender = false
        return if self.recording.is_replaying? && sender != :replay
        return if @previous_right_analog_y_player_2 == value
        @previous_right_analog_y_player_2 = value
        self.record_input_history :right_analog_y_player_2, value, 0, 1
        __controller_analog_set_last_active_if_needed__ @args.inputs.controller_two, value
        value = 0 if value.abs <= analog_dead_zone
        @args.inputs.controller_two.right_analog_y_raw = value.*(-1)
        @args.inputs.controller_two.right_analog_y_perc = analog_to_perc value.*(-1)
      end

      # =============================================
      # PLAYER 3
      # =============================================
      def controller_three_connected name
        @args.inputs.controller_three.connected = true
        @args.inputs.controller_three.name = name
      end

      def controller_three_disconnected
        @args.inputs.controller_three.connected = false
        reset_controller_last_active_if_needed
      end

      def key_down_player_three raw_key, sender = false
        controller_key_down(3, raw_key, sender)
      end

      def key_held_player_three raw_key, sender = false
        controller_key_held(3, raw_key, sender)
      end

      def key_up_player_three raw_key, sender = false
        controller_key_up(3, raw_key, sender)
      end

      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def left_analog_x_player_3 value, sender = false
        return if self.recording.is_replaying? && sender != :replay
        return if @previous_left_analog_x_player_3 == value
        @previous_left_analog_x_player_3 = value
        self.record_input_history :left_analog_x_player_3, value, 0, 1
        __controller_analog_set_last_active_if_needed__ @args.inputs.controller_three, value
        value = 0 if value.abs <= analog_dead_zone
        @args.inputs.controller_three.left_analog_x_raw = value
        @args.inputs.controller_three.left_analog_x_perc = analog_to_perc value
      end

      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def left_analog_y_player_3 value, sender = false
        return if self.recording.is_replaying? && sender != :replay
        return if @previous_left_analog_y_player_3 == value
        @previous_left_analog_y_player_3 = value
        self.record_input_history :left_analog_y_player_3, value, 0, 1
        __controller_analog_set_last_active_if_needed__ @args.inputs.controller_three, value
        value = 0 if value.abs <= analog_dead_zone
        @args.inputs.controller_three.left_analog_y_raw = value.*(-1)
        @args.inputs.controller_three.left_analog_y_perc = analog_to_perc value.*(-1)
      end

      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def right_analog_x_player_3 value, sender = false
        return if self.recording.is_replaying? && sender != :replay
        return if @previous_right_analog_x_player_3 == value
        @previous_right_analog_x_player_3 = value
        self.record_input_history :right_analog_x_player_3, value, 0, 1
        __controller_analog_set_last_active_if_needed__ @args.inputs.controller_three, value
        value = 0 if value.abs <= analog_dead_zone
        @args.inputs.controller_three.right_analog_x_raw = value
        @args.inputs.controller_three.right_analog_x_perc = analog_to_perc value
      end

      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def right_analog_y_player_3 value, sender = false
        return if self.recording.is_replaying? && sender != :replay
        return if @previous_right_analog_y_player_3 == value
        @previous_right_analog_y_player_3 = value
        self.record_input_history :right_analog_y_player_3, value, 0, 1
        __controller_analog_set_last_active_if_needed__ @args.inputs.controller_three, value
        value = 0 if value.abs <= analog_dead_zone
        @args.inputs.controller_three.right_analog_y_raw = value.*(-1)
        @args.inputs.controller_three.right_analog_y_perc = analog_to_perc value.*(-1)
      end

      # =============================================
      # PLAYER 4
      # =============================================
      def controller_four_connected name
        @args.inputs.controller_four.connected = true
        @args.inputs.controller_four.name = name
      end

      def controller_four_disconnected
        @args.inputs.controller_four.connected = false
        reset_controller_last_active_if_needed
      end

      def key_down_player_four raw_key, sender = false
        controller_key_down(4, raw_key, sender)
      end

      def key_held_player_four raw_key, sender = false
        controller_key_held(4, raw_key, sender)
      end

      def key_up_player_four raw_key, sender = false
        controller_key_up(4, raw_key, sender)
      end

      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def left_analog_x_player_4 value, sender = false
        return if self.recording.is_replaying? && sender != :replay
        return if @previous_left_analog_x_player_4 == value
        @previous_left_analog_x_player_4 = value
        self.record_input_history :left_analog_x_player_4, value, 0, 1
        __controller_analog_set_last_active_if_needed__ @args.inputs.controller_four, value
        value = 0 if value.abs <= analog_dead_zone
        @args.inputs.controller_four.left_analog_x_raw = value
        @args.inputs.controller_four.left_analog_x_perc = analog_to_perc value
      end

      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def left_analog_y_player_4 value, sender = false
        return if self.recording.is_replaying? && sender != :replay
        return if @previous_left_analog_y_player_4 == value
        @previous_left_analog_y_player_4 = value
        self.record_input_history :left_analog_y_player_4, value, 0, 1
        __controller_analog_set_last_active_if_needed__ @args.inputs.controller_four, value
        value = 0 if value.abs <= analog_dead_zone
        @args.inputs.controller_four.left_analog_y_raw = value.*(-1)
        @args.inputs.controller_four.left_analog_y_perc = analog_to_perc value.*(-1)
      end

      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def right_analog_x_player_4 value, sender = false
        return if self.recording.is_replaying? && sender != :replay
        return if @previous_right_analog_x_player_4 == value
        @previous_right_analog_x_player_4 = value
        self.record_input_history :right_analog_x_player_4, value, 0, 1
        __controller_analog_set_last_active_if_needed__ @args.inputs.controller_four, value
        value = 0 if value.abs <= analog_dead_zone
        @args.inputs.controller_four.right_analog_x_raw = value
        @args.inputs.controller_four.right_analog_x_perc = analog_to_perc value
      end

      # WARNING: do not update this function signature or you'll break replays. create a new function instead
      def right_analog_y_player_4 value, sender = false
        return if self.recording.is_replaying? && sender != :replay
        return if @previous_right_analog_y_player_4 == value
        @previous_right_analog_y_player_4 = value
        __controller_analog_set_last_active_if_needed__ @args.inputs.controller_four, value
        value = 0 if value.abs <= analog_dead_zone
        @args.inputs.controller_four.right_analog_y_raw = value.*(-1)
        @args.inputs.controller_four.right_analog_y_perc = analog_to_perc value.*(-1)
      end

      def background_color
        @args.outputs.background_color
      end

      def rawjoystick_connected jid, joystickname, guid
        self.controller_config.rawjoystick_connected jid, joystickname, guid
      end

      def rawjoystick_disconnected jid
        self.controller_config.rawjoystick_disconnected jid
      end

      def rawjoystick_axis jid, axis, value
        self.controller_config.rawjoystick_axis jid, axis, value
      end

      def rawjoystick_hat jid, hat, value
        self.controller_config.rawjoystick_hat jid, hat, value
      end

      def rawjoystick_button jid, button, pressed
        self.controller_config.rawjoystick_button jid, button, pressed
      end

      def left_controller_position x, y, z, orientation_x, orientation_y, orientation_z
        @args.inputs.controller_one.left_hand.position.x = x
        @args.inputs.controller_one.left_hand.position.y = y
        @args.inputs.controller_one.left_hand.position.z = z
        @args.inputs.controller_one.left_hand.orientation.x = orientation_x
        @args.inputs.controller_one.left_hand.orientation.y = orientation_y
        @args.inputs.controller_one.left_hand.orientation.z = orientation_z
      end

      def right_controller_position x, y, z, orientation_x, orientation_y, orientation_z
        @args.inputs.controller_one.right_hand.position.x = x
        @args.inputs.controller_one.right_hand.position.y = y
        @args.inputs.controller_one.right_hand.position.z = z
        @args.inputs.controller_one.right_hand.orientation.x = orientation_x
        @args.inputs.controller_one.right_hand.orientation.y = orientation_y
        @args.inputs.controller_one.right_hand.orientation.z = orientation_z
      end

      def headset_position x, y, z, orientation_x, orientation_y, orientation_z
        @args.inputs.headset.position.x = x
        @args.inputs.headset.position.y = y
        @args.inputs.headset.position.z = z
        @args.inputs.headset.orientation.x = orientation_x
        @args.inputs.headset.orientation.y = orientation_y
        @args.inputs.headset.orientation.z = orientation_z
      end

      def windowevent_size_changed orientation_w, orientation_h,
                                   window_width, window_height,
                                   allscreen_width_px, allscreen_height_px,
                                   allscreen_offset_x_px, allscreen_offset_y_px,
                                   texture_scale, texture_scale_enum
        g = @args.grid

        # indicates that orientation was changed
        if orientation_w != g.w
          @args.events[:orientation_changed] = true
          if @orientation == :landscape
            @orientation = :portrait
            @logical_width, @logical_height = @logical_height, @logical_width
          else
            @orientation = :landscape
            @logical_width, @logical_height = @logical_height, @logical_width
          end

          if Grid.origin_name == :bottom_left
            Grid.origin_bottom_left!(force: true)
          else
            Grid.origin_center!(force: true)
          end

          Layout.orientation_changed!
        end

        g.allscreen_w_pt        = window_width
        g.allscreen_h_pt        = window_height
        g.texture_scale         = texture_scale.to_f
        g.texture_scale_enum    = texture_scale_enum

        g.allscreen_w_px        = allscreen_width_px
        g.allscreen_h_px        = allscreen_height_px
        g.allscreen_offset_x_px = allscreen_offset_x_px
        g.allscreen_offset_y_px = allscreen_offset_y_px

        g.w                     = orientation_w
        g.h                     = orientation_h
        g.w_px                  = (orientation_w * texture_scale).ceil
        g.h_px                  = (orientation_h * texture_scale).ceil

        g.allscreen_w           = (g.allscreen_w_px / texture_scale).ceil
        g.allscreen_h           = (g.allscreen_h_px / texture_scale).ceil
        g.allscreen_offset_x    = (g.allscreen_offset_x_px / texture_scale).ceil
        g.allscreen_offset_y    = (g.allscreen_offset_y_px / texture_scale).ceil

        g.allscreen_left_px     = -g.allscreen_offset_x_px
        g.allscreen_bottom_px   = -g.allscreen_offset_y_px
        g.allscreen_left        = -g.allscreen_offset_x
        g.allscreen_bottom      = -g.allscreen_offset_y

        g.allscreen_right_px    = g.allscreen_left_px   + g.allscreen_w_px + g.allscreen_offset_x_px
        g.allscreen_top_px      = g.allscreen_bottom_px + g.allscreen_h_px + g.allscreen_offset_y_px
        g.allscreen_right       = g.allscreen_left      + g.allscreen_w    + g.allscreen_offset_x
        g.allscreen_top         = g.allscreen_bottom    + g.allscreen_h    + g.allscreen_offset_y

        g.bottom         = 0
        g.left           = 0
        g.right          = g.w
        g.top            = g.h
        g.bottom_px      = 0
        g.left_px        = 0
        g.right_px       = g.w_px
        g.top_px         = g.h_px

        if @args.grid.origin_name == :center
          g.allscreen_left_px   -= (g.allscreen_w_px / 2).ceil
          g.allscreen_right_px  -= (g.allscreen_w_px / 2).ceil
          g.allscreen_bottom_px -= (g.allscreen_h_px / 2).ceil
          g.allscreen_top_px    -= (g.allscreen_h_px / 2).ceil
          g.allscreen_left      -= (g.allscreen_w / 2).ceil
          g.allscreen_right     -= (g.allscreen_w / 2).ceil
          g.allscreen_bottom    -= (g.allscreen_h / 2).ceil
          g.allscreen_top       -= (g.allscreen_h / 2).ceil
          g.left_px             -= (g.w_px / 2).ceil
          g.right_px            -= (g.w_px / 2).ceil
          g.bottom_px           -= (g.h_px / 2).ceil
          g.top_px              -= (g.h_px / 2).ceil
          g.left                -= (g.w / 2).ceil
          g.right               -= (g.w / 2).ceil
          g.bottom              -= (g.h / 2).ceil
          g.top                 -= (g.h / 2).ceil
        end

        @args.events[:resize_occurred] = true
      end

      def raw_event event
        @args.events[:raw] << event
        if event[:type] == :a11y_activation_event
          @args.inputs.a11y[:activated] = true
          @args.inputs.a11y[:activated_at] = Kernel.tick_count
          @args.inputs.a11y[:activated_global_at] = Kernel.global_tick_count
          @args.inputs.a11y[:activated_global_at_raw] = event[:activated_global_at]
          @args.inputs.a11y[:activated_id] = event[:activated_id]
        end
      end
    end # end CBridge module
  end # end Runtime class
end # end GTK module
