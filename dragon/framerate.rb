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

      def reset_framerate_calculation
        @tick_speed_sum = 0
        @tick_speed_count = 0
        @previous_framerate = 0
      end

      def check_framerate
        if @framerate_diagnostics_requested
          log "================================"
          log framerate_get_diagnostics
          @framerate_diagnostics_requested = false
        end

        if !@paused
          if @tick_time
            @tick_speed_count += 1
            @tick_speed_sum += Time.now.to_i - @tick_time
            if @tick_speed_count > 60 * 2
              if framerate_below_threshold?
                @last_framerate = current_framerate
                if !@console.visible?
                  if !@framerate_important_notification_happened
                    log_important framerate_warning_message
                  else
                    log framerate_warning_message
                  end
                  @framerate_important_notification_happened = true
                end
              end

              @previous_framerate = current_framerate.floor
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
        @last_framerate ||= 60
        current_framerate < @last_framerate &&
          current_framerate < 50 &&
          @previous_framerate > current_framerate &&
          Kernel.tick_count > 600
      end

      def current_framerate
        return 60 if !@tick_speed_sum || !@tick_speed_sum
        r = 100.fdiv(@tick_speed_sum.fdiv(@tick_speed_count) * 100)
        if (r.nan? || r.infinite? || r > 58)
          r = 60
        end
        r || 60
      rescue
        60
      end
    end # module Framerate
  end # end class Runtime
end # end module GTK
