# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# easing.rb has been released under MIT (*only this file*).

module GTK
  module Easing
    def self.ease start_tick, current_tick, duration, *definitions
      ease_extended start_tick,
                    current_tick,
                    start_tick + duration,
                    initial_value(*definitions),
                    final_value(*definitions),
                    *definitions
    end

    def self.ease_extended start_tick, current_tick, end_tick, default_before, default_after, *definitions
      definitions.flatten!
      definitions = [:identity] if definitions.length == 0
      duration = end_tick - start_tick
      elapsed  = current_tick - start_tick
      y = elapsed.percentage_of(duration).cap_min_max(0, 1)

      definitions.map do |definition|
        y = Easing.exec_definition(definition, start_tick, duration, y)
      end

      y
    end

    def self.ease_spline start_tick, current_tick, duration, spline
      ease_spline_extended start_tick, current_tick, start_tick + duration, spline
    end

    def self.ease_spline_extended start_tick, current_tick, end_tick, spline
      return spline[-1][-1] if current_tick >= end_tick
      duration = end_tick - start_tick
      t = (current_tick - start_tick).fdiv duration
      time_allocation_per_curve = 1.fdiv(spline.length)
      curve_index, curve_t = t.fdiv(time_allocation_per_curve).let do |spline_t|
        [spline_t.to_i, spline_t - spline_t.to_i]
      end
      Geometry.cubic_bezier curve_t, *spline[curve_index]
    end

    def self.initial_value *definitions
      definitions.flatten!
      return Easing.exec_definition (definitions.at(-1) || :identity), 0, 10, 0
    end

    def self.final_value *definitions
      definitions.flatten!
      return Easing.exec_definition (definitions.at(-1) || :identity), 0, 10, 1.0
    end

    def self.exec_definition definition, start_tick, duration, x
      if definition.is_a? Symbol
        return Easing.send(definition, x).cap_min_max(0, 1)
      elsif definition.is_a? Proc
        return definition.call(x, start_tick, duration).cap_min_max(0, 1)
      end

      raise <<-S
* ERROR:
I don't know how to execute easing function with definition #{definition}.

S
    end

    def self.identity x
      x
    end

    def self.flip x
      1 - x
    end

    def self.quad x
      x * x
    end

    def self.cube x
      x * x * x
    end

    def self.quart x
      x * x * x * x * x
    end

    def self.quint x
      x * x * x * x * x * x
    end
  end
end

Easing = GTK::Easing
