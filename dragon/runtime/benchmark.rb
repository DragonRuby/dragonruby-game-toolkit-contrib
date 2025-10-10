# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# benchmark.rb has been released under MIT (*only this file*).

module GTK
    class Benchmark; class << self
      def benchmark_iterations_single iterations, name, proc
        idx = 0
        r = nil
        time_start = Time.now
        while idx < iterations
          r = proc.call
          idx += 1
        end
        elapsed_time = (Time.now - time_start).round(3)

        { name: name,
          iterations: iterations,
          time: elapsed_time.round(3),
          time_ms: (elapsed_time * 1000).to_i }
      end

      def benchmark_seconds_single seconds, name, proc
        elapsed_time = 0
        iterations = 0
        time_start = Time.now
        while elapsed_time < seconds
          proc.call
          iterations += 1
          elapsed_time = Time.now - time_start
        end

        { name: name,
          iterations: iterations,
          time: elapsed_time.round(3),
          time_ms: (elapsed_time * 1000).to_i }
      end

      def benchmark(opts = nil, **kwargs)
        # !!! NOTE: Ruby 3.1 breaks the duality of being able to pass in
        #           a hash or kwargs. This null check + kwargs assignment is added
        #           for backwards compat
        if kwargs.iterations
          benchmark_iterations(opts, **kwargs)
        elsif kwargs.seconds
          benchmark_seconds(opts, **kwargs)
        else
          raise <<-S
* ERROR:
Runtime#benchmark must be given either ~iterations~ or ~seconds~

Example:
#+begin_src
  GTK.benchmark iterations: 10_000, variation_1: lambda { }, variation_2: lambda { }
  # OR
  GTK.benchmark seconds: 10, variation_1: lambda { }, variation_2: lambda { }
#+end_src
S
        end
      end

      def benchmark_seconds(opts = nil, **kwargs)
        # !!! NOTE: Ruby 3.1 breaks the duality of being able to pass in
        #           a hash or kwargs. This null check + kwargs assignment is added
        #           for backwards compat
        kwargs = opts if opts
        seconds = kwargs.seconds || 5

        procs = kwargs.find_all { |k, v| v.respond_to? :call }

        iterations = procs.map do |(name, proc)|
          benchmark_seconds_single seconds, name, proc
        end.sort_by { |r| -r.iterations }

        first_place = iterations.first
        second_place = iterations.second || first_place

        iterations = iterations.map do |candidate|
          average_iteration = first_place.iterations

          difference_percentage = 0
          if average_iteration == 0
            difference_percentage = 0
          elsif average_iteration == candidate.iterations
            difference_percentage = 0
          else
            difference_percentage = ((first_place.iterations / candidate.iterations) * 100).round - 100
          end

          difference_iterations = first_place.iterations - candidate.iterations
          candidate.merge(difference_percentage: difference_percentage,
                          difference_iterations: difference_iterations)
        end

        summary = <<-S
* BENCHMARK WINNER: #{first_place.name}
** Caller:         #{(caller || []).first}
** Duration:       #{kwargs.seconds}s
S
        too_small_to_measure = false
        if (first_place.iterations + second_place.iterations) == 0
          too_small_to_measure = true
          difference_percentage = 0
        summary = <<-S

* BENCHMARK WINNER: inconclusive
** Caller:         #{(caller || []).first}
** Duration:       #{first_place.iterations.to_si}
S
          summary += <<-S
** Average iterations for experiments were too small. Increase the number of seconds to run.
S
        else
          difference_percentage = ((first_place.iterations / second_place.iterations) * 100).round
        end

        difference_iterations = (first_place.iterations - second_place.iterations).abs.round

        r = {
          iterations: iterations,
          first_place: first_place,
          second_place: second_place,
          difference_iterations: difference_iterations,
          difference_percentage: difference_percentage,
          too_small_to_measure: too_small_to_measure
        }

        log_message = []
        only_one_result = first_place.name == second_place.name

        if only_one_result
        summary = <<-S
BENCHMARK WINNER: #{r.first_place.name}
S
        else
          summary += <<-S
** Most Completed: #{r.first_place.name}
** Second Most:    #{r.second_place.name}
** Margin %:       #{r.second_place.name} did #{r.difference_percentage - 100}% fewer iterations than #{r.first_place.name}
** Margin Count:   #{r.second_place.name} completed #{r.difference_iterations.abs.to_si} fewer iterations than #{r.first_place.name} (#{r.second_place.iterations.to_si} vs #{r.first_place.iterations.to_si})
** Counts:
#{r.iterations.map { |t| "*** #{t.name}: total: #{t.iterations.to_si}, perc: #{t.difference_percentage}% fewer, diff: #{t.difference_iterations.abs.to_si}." }.join("\n")}
S
        end

        log summary
        r
      end

      def benchmark_iterations(opts = nil, **kwargs)
        # !!! NOTE: Ruby 3.1 breaks the duality of being able to pass in
        #           a hash or kwargs. This null check + kwargs assignment is added
        #           for backwards compat
        kwargs = opts if opts
        iterations = kwargs.iterations
        procs = kwargs.find_all { |k, v| v.respond_to? :call }

        times = procs.map do |(name, proc)|
          benchmark_iterations_single iterations, name, proc
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
            difference_percentage = ((((candidate.time * 1000) / (first_place.time * 1000))) * 100).round - 100
            difference_percentage = 0 if difference_percentage < 0
          end

          difference_time = ((first_place.time - candidate.time) * 1000).round
          candidate.merge(difference_percentage: difference_percentage,
                          difference_time: difference_time)
        end

        summary = <<-S

* BENCHMARK WINNER: #{first_place.name}
** Caller:     #{(caller || []).first}
** Iterations: #{first_place.iterations.to_si}
S
        too_small_to_measure = false
        if (first_place.time + second_place.time) == 0
          too_small_to_measure = true
          difference_percentage = 0
        summary = <<-S

* BENCHMARK WINNER: inconclusive
** Caller:     #{(caller || []).first}
** Iterations: #{first_place.iterations.to_si}
S
          summary += <<-S
** Average time for experiments were too small. Increase the number of iterations.
S
        else
          difference_percentage = ((((second_place.time * 1000) / (first_place.time * 1000))) * 100).round - 100
          difference_percentage = 0 if difference_percentage < 0
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

* BENCHMARK WINNER: #{r.first_place.name} completed in #{r.first_place.time_ms}ms.
S
        else
          summary += <<-S
** Fastest:    #{r.first_place.name}
** Second:     #{r.second_place.name}
** Margin %:   #{r.second_place.name} was #{r.difference_percentage}% slower than #{r.first_place.name}
** Margin ms:  #{r.second_place.name} took #{r.difference_time.abs}ms longer than #{r.first_place.name} (#{r.first_place.time_ms}ms vs #{r.second_place.time_ms}ms)
** Times:
#{r.times.map { |t| "*** #{t.name}: total: #{t.time_ms}ms, perc: #{t.difference_percentage}% slower, diff: #{t.difference_time.abs}ms." }.join("\n")}
S
        end

        log summary
        r
      end

  end; end
end
