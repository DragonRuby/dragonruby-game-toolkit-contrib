# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# tick.rb has been released under MIT (*only this file*).

module GTK
  class Runtime
    module Tick
      def tick_core
        @is_inside_tick = true
        $top_level.tick @args if Kernel.tick_count >= 0
        @is_inside_tick = false
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
