# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# tick.rb has been released under MIT (*only this file*).

module GTK
  class Runtime
    module Tick
      # will be invoked if Kernel.global_tick_count == 0
      def boot_core
        $main.args = @args
        if $main.respond_to? :boot
          if $main.method(:boot).arity == 1
            $main.boot @args
          else
            $main.boot
          end
        end
      end

      # will be invoked if DR.reset is invoked,
      # before internal reset is performed
      # Kernel.tick_count will be the frame reset was invoked
      def reset_core
        $main.args = @args
        if $main.respond_to? :reset
          if $main.method(:reset).arity == 1
            $main.reset @args
          else
            $main.reset
          end
        end
      end

      # will be invoked if DR.reset is invoked,
      # after internal reset is performed
      # Kernel.tick_count will be -1
      def did_reset_core
        $main.args = @args
        if $main.respond_to? :did_reset
          if $main.method(:did_reset).arity == 1
            $main.did_reset @args
          else
            $main.did_reset
          end
        end
      end

      # core tick function that invokes
      # tick in user code
      def tick_core
        @is_inside_tick = true

        $main.args = @args

        if Kernel.tick_count == 0
          if $main.respond_to?(:tick)
            @tick_method = $main.method(:tick)
          end

          if $main.singleton_class.instance_methods.include?(:start)
            if $main.method(:start).arity == 1
              $main.start @args
            else
              $main.start
            end
          end
        end

        $main.method_missing :tick if !@tick_method

        if Kernel.tick_count >= 0
          if @tick_method.arity == 1
            $main.tick @args
          else
            $main.tick
          end
        end

        @is_inside_tick = false
      end

      def shutdown_core
        if $main.respond_to?(:shutdown)
          $main.args = @args
          if $main.method(:shutdown).arity == 1
            $main.shutdown @args
          else
            $main.shutdown
          end
        end
      end

      def inside_tick?
        @is_inside_tick
      end
    end
  end
end

module GTK
  class Runtime
    include Tick
  end
end
