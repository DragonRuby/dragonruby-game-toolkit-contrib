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
      log_once :consider_smooth!, "Easing::ease can be expensive to invoke, consider using Easing.smooth_(start|stop|step) instead.", include_caller: true
      definitions.flatten!
      definitions = [:identity] if definitions.length == 0
      duration = end_tick - start_tick
      elapsed  = current_tick - start_tick
      y = elapsed.fdiv(duration).clamp(0, 1)

      Array.each(definitions) do |definition|
        y = Easing.exec_definition(definition, start_tick, duration, y)
      end

      y
    end

    def self.ease_spline start_tick, current_tick, duration, spline
      ease_spline_extended start_tick, current_tick, start_tick + duration, spline
    end

    def self.spline start_tick, current_tick, duration, spline
      ease_spline_extended start_tick, current_tick, start_tick + duration, spline
    end

    def self.ease_spline_extended start_tick, current_tick, end_tick, spline
      return spline[-1][-1] if current_tick >= end_tick
      duration = end_tick - start_tick
      t = (current_tick - start_tick).fdiv duration
      time_allocation_per_curve = 1.fdiv(spline.length)
      spline_t = t.fdiv(time_allocation_per_curve)
      curve_index = spline_t.to_i
      curve_t = spline_t - spline_t.to_i
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
        return Easing.send(definition, x).clamp(0, 1)
      elsif definition.is_a? Proc
        return definition.call(x, start_tick, duration).clamp(0, 1)
      end

      raise <<-S
* ERROR:
I don't know how to execute easing function with definition #{definition}.

S
    end

    def self.mix a, b, perc
      a * (1 - perc) + b * perc
    end

    def self.__resolve_params__(m:,
                                initial: nil, final: nil, perc: nil,
                                start_at: nil, end_at: nil,
                                duration: nil, tick_count: nil, power: nil)

      tick_count ||= Kernel.tick_count
      power ||= 1

      if initial && final && perc
        return { initial: initial, final: final, perc: perc, power: power }
      end

      if (start_at && end_at) || (start_at && duration)
        end_at     ||= start_at + duration
        initial      = 0
        final        = 1
        perc         = (tick_count - start_at).fdiv(end_at - start_at).clamp(0, 1)
        perc         = 0 if start_at > tick_count
        perc         = 1 if end_at < tick_count
        return { initial: initial, final: final, perc: perc, power: power }
      end

      missing_perc_params = []
      missing_perc_params << :initial    if !initial
      missing_perc_params << :final      if !final
      missing_perc_params << :perc       if !perc

      missing_time_params = []
      missing_time_params << :start_at   if !start_at
      missing_time_params << :duration   if !end_at && !duration
      missing_time_params << :end_at     if !end_at && !duration

      raise <<~S
            * ERROR: Easing::#{m} failed to resolve parameters.
            ** Given keyword arguments:
            - initial:    #{initial.inspect}
            - final:      #{final.inspect}
            - perc:       #{perc.inspect}
            - start_at:   #{start_at.inspect}
            - end_at:     #{end_at.inspect}
            - duration:   #{duration.inspect}
            - tick_count: #{tick_count.inspect}
            - power:      #{power.inspect}
            ** Easing::#{m} requires one of the following keyword arguments combinations
            *** Percentage-based
            Example:
            #+begin_src ruby
              # NOTE:
              # power is optional and will default to 1
              Easing.#{m} initial: #{initial || "REQUIRED"}, final: #{final || "REQUIRED"}, perc: #{perc || "REQUIRED"}, power: #{power}
            #+end_src
            *** Time-based
            Example:
            #+begin_src ruby
              # NOTE:
              # power is optional and will default to 1
              # tick_count is optional and will default to Kernel.tick_count
              Easing.#{m} start_at: #{start_at || "REQUIRED"}, end_at: #{end_at || "REQUIRED"}, tick_count: #{tick_count}, power: #{power}
              # OR
              Easing.#{m} start_at: #{start_at || "REQUIRED"}, duration: #{duration || "REQUIRED"}, tick_count: #{tick_count}, power: #{power}
            #+end_src
            S
    end



    def self.smooth_step(initial: nil, final: nil, perc: nil,
                         start_at: nil, end_at: nil, duration: nil,
                         tick_count: nil, power: 1, flip: false)

      params = __resolve_params__ m: :smooth_step,
                                  initial: initial, final: final, perc: perc,
                                  start_at: start_at, end_at: end_at,
                                  duration: duration, tick_count: tick_count, power: power

      start = smooth_start params
      stop = smooth_stop params
      r = mix start, stop, 0.5
      r = 1 - r if flip
      r
    end

    def self.smooth_start(initial: nil, final: nil, perc: nil,
                          start_at: nil, end_at: nil, duration: nil,
                          tick_count: nil, power: 1, flip: false)

      params = __resolve_params__ m: :smooth_start,
                                  initial: initial, final: final, perc: perc,
                                  start_at: start_at, end_at: end_at,
                                  duration: duration, tick_count: tick_count, power: power

      r = params.initial + (params.perc**params.power) * (params.final - params.initial)
      r = 1 - r if flip
      r
    end

    def self.smooth_stop(initial: nil, final: nil, perc: nil,
                         start_at: nil, end_at: nil, duration: nil,
                         tick_count: nil, power: 1, flip: false)

      params = __resolve_params__ m: :smooth_stop,
                                  initial: initial, final: final, perc: perc,
                                  start_at: start_at, end_at: end_at,
                                  duration: duration, tick_count: tick_count, power: power

      r = params.initial + (1 - (1 - params.perc)**params.power) * (params.final - params.initial)
      r = 1 - r if flip
      r
    end

    def self.identity x
      x
    end

    def self.flip x
      1 - x
    end

    def self.quad x
      x**2
    end

    def self.cube x
      x**3
    end

    def self.quart x
      x**4
    end

    def self.quint x
      x**4
    end

    def self.smooth_start_quad x
      x**2
    end

    def self.smooth_stop_quad x
      1 - (1 - x)**2
    end

    def self.smooth_start_cube x
      x**3
    end

    def self.smooth_stop_cube x
      1 - (1 - x)**3
    end

    def self.smooth_start_quart x
      x**4
    end

    def self.smooth_stop_quart x
      1 - (1 - x)**4
    end

    def self.smooth_start_quint x
      x**5
    end

    def self.smooth_stop_quint x
      1 - (1 - x)**5
    end
  end
end

Easing = GTK::Easing
