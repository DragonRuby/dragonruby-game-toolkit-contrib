# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# notify.rb has been released under MIT (*only this file*).

module GTK
  module Notify
    def notify message, duration = 300
      notify! message, duration
    end

    def notify! message, duration = 300
      return if self.production
      message ||= ""
      message = "#{message}"
      return if @notification_message == message
      return if @production
      @global_notification_at = Kernel.global_tick_count
      @notification_duration = duration
      @notification_message = message
      @console.add_text "* NOTIFY: #{message}" if message.strip.length > 0
    end

    def notify_subdued!
      notify! "", 60
    end

    def notify_extended! opts = {}
      message   = opts.message  || ""
      duration  = opts.duration || 300
      env       = opts.env      || :dev
      a         = opts.a        || 255
      overwrite = opts.overwrite
      return if @production && env != :prod
      return if !overwrite && @notification_message == message
      @global_notification_at = Kernel.global_tick_count
      @notification_duration = duration
      @notification_message = message
      @notification_max_alpha = a
      @console.add_text "* NOTIFY: #{message}" if message.strip.length > 0
    end

    alias notify_extended notify_extended!

    def tick_notification
      return if Kernel.tick_count <= -1
      @notification_max_alpha ||= 255
      @notification_message = nil if @console.visible?
      return if !@notification_message
      return if !@notification_duration
      return if !@global_notification_at
      if Kernel.global_tick_count > @global_notification_at + @notification_duration
        @notification_message = nil
        @global_notification_at = nil
        @notification_duration = nil
        return
      end

      fade_in_at = @global_notification_at
      hold_at = @global_notification_at + 15
      fade_out_at = @global_notification_at + @notification_duration - 15
      alpha = if Kernel.global_tick_count > fade_out_at
                Easing.smooth_start(start_at: fade_out_at,
                                    tick_count: Kernel.global_tick_count,
                                    duration: 15,
                                    flip: true) * 255
              elsif Kernel.global_tick_count > hold_at
                255
              else
                Easing.smooth_start(start_at: fade_in_at,
                                    tick_count: Kernel.global_tick_count,
                                    duration: 15) * 255
              end

      logo_y = @args.grid.bottom

      if @notification_message.length != 0
        max_character_length = if Grid.orientation == :landscape
                                 110
                               else
                                 60
                               end
        line_height = 30
        long_string = @notification_message.strip
        long_strings_split = args.string.wrapped_lines long_string, max_character_length
        @args.outputs.reserved << long_strings_split.map_with_index do |s, i|
          { x: @args.grid.left,
            y: args.grid.bottom + i * 40,
            w: @logical_width,
            h: 40,
            path: :solid,
            r: 0,
            g: 0,
            b: 0,
            a: alpha }
        end

        @args.outputs.reserved << long_strings_split.reverse.map_with_index do |s, i|
          { x: @args.grid.left + 60,
            y: @args.grid.bottom + 30 + i * 40,
            text: s.lstrip,
            r: 255,
            g: 255,
            b: 255,
            a: alpha }
        end

        logo_y = @args.grid.bottom + (long_strings_split.length * 40).idiv(2) - 20
      end

      @args.outputs.reserved << { x: @args.grid.left + 10, y: logo_y, w: 40, h: 40, path: 'console-logo.png', a: alpha }
    end
  end
end
