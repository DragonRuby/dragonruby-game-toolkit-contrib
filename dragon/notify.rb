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
      overwrite = opts.overwrite
      return if env != :prod && self.production
      return if !overwrite && @notification_message == message
      @global_notification_at = Kernel.global_tick_count
      @notification_duration = duration
      @notification_message = message
      @console.add_text "* NOTIFY: #{message}" if message.strip.length > 0
    end

    def tick_notification
      @notification_message = nil if @console.visible?
      if @notification_message && @global_notification_at.elapsed_time(Kernel.global_tick_count) < @notification_duration
        diff = @notification_duration - @global_notification_at.elapsed_time(Kernel.global_tick_count)
        alpha = @global_notification_at.global_ease(15, :identity) * 255
        if diff < 15
          alpha = @global_notification_at.+(@notification_duration - 15).global_ease(15, :flip) * 255
        end
        if @notification_message.length != 0
          @args.outputs.reserved << { x: @args.grid.left, y: args.grid.bottom, w: @logical_width, h: 40, r: 0, g: 0, b: 0, a: alpha }.solid!
          @args.outputs.reserved << { x: @args.grid.left + 60, y: @args.grid.bottom + 30, text: @notification_message, r: 255, g: 255, b: 255, a: alpha }
        end
        @args.outputs.reserved << { x: @args.grid.left + 10, y: @args.grid.bottom, w: 40, h: 40, path: 'console-logo.png', a: alpha }
      else
        @notification_message = nil
      end
    end
  end
end
