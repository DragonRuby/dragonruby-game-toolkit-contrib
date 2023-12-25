# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# benchmark.rb has been released under MIT (*only this file*).

module GTK
  class Runtime
    module Benchmark
      def benchmark_single iterations, name, proc
        idx = 0
        r = nil
        time_start = Time.now
        while idx < iterations
          r = proc.call
          idx += 1
        end
        result = (Time.now - time_start).round 3

        { name: name,
          time: result,
          time_ms: (result * 1000).to_i }
      end

      def benchmark opts = {}
        iterations = opts.iterations
        iterations_with_seperator = iterations.to_s.reverse.each_char.each_slice(3).map(&:join).join("_").reverse
        procs = opts.find_all { |k, v| v.respond_to? :call }

        times = procs.map do |(name, proc)|
          benchmark_single iterations, name, proc
        end.sort_by { |r| r.time }

        first_place = times.first
        second_place = times.second || first_place

        times = times.map do |candidate|
          average_time = first_place.time

          difference_percentage = 0
          if average_time == 0
            difference_percentage = 0
          elsif average_time == candidate.time
            difference_percentage = 0
          else
            difference_percentage = ((((candidate.time * 1000) / (first_place.time * 1000))) * 100).round
          end

          difference_time = ((first_place.time - candidate.time) * 1000).round
          candidate.merge(difference_percentage: difference_percentage,
                          difference_time: difference_time)
        end

        summary = <<-S

* BENCHMARK RESULT: #{first_place.name} is fastest
** Caller: #{(caller || []).first}
** Iterations: #{iterations_with_seperator}
S
        too_small_to_measure = false
        if (first_place.time + second_place.time) == 0
          too_small_to_measure = true
          difference_percentage = 0
        summary = <<-S

* BENCHMARK RESULT: inconclusive
** Caller: #{(caller || []).first}
** Iterations: #{iterations_with_seperator}
S
          summary += <<-S
** Average time for experiments were too small. Increase the number of iterations.
S
        else
          difference_percentage = ((((second_place.time * 1000) / (first_place.time * 1000))) * 100).round
        end

        difference_time = first_place.time.-(second_place.time).*(1000).abs.round

        r = {
          iterations: iterations,
          first_place: first_place,
          second_place: second_place,
          difference_time: difference_time,
          difference_percentage: difference_percentage,
          times: times,
          too_small_to_measure: too_small_to_measure
        }

        log_message = []
        only_one_result = first_place.name == second_place.name

        if only_one_result
        summary = <<-S

* BENCHMARK RESULT: #{r.first_place.name} completed in #{r.first_place.time_ms}ms.
S
        else
          summary += <<-S
** Fastest:    #{r.first_place.name}
** Second:     #{r.second_place.name}
** Margin %:   #{r.second_place.name} was #{r.difference_percentage}% slower than #{r.first_place.name}
** Margin ms:  #{r.second_place.name} took #{r.difference_time.abs}ms longer than #{r.first_place.name} (#{r.first_place.time_ms}ms vs #{r.second_place.time_ms}ms)
** Times:
#{r.times.map { |t| "*** #{t.name}: #{t.time_ms}ms (#{t.difference_percentage}% #{t.difference_time.abs}ms)." }.join("\n")}
S
        end

        log summary
        r
      end
    end
  end
end
