# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# process_argsv.rb has been released under MIT (*only this file*).

module GTK
  class Runtime
    module ProcessARGSV
      def process_argsv
        return if @argsv_processed

        @simulation_speed = (cli_arguments[:speed] || "1").to_i
        @simulation_speed = @simulation_speed.abs
        @simulation_speed = 1 if @simulation_speed == 0

        if cli_arguments.keys.include? :scale
          set_window_scale cli_arguments[:scale].to_f
        end

        if cli_arguments.keys.include? :record
          @argsv_processed = true
          seed = cli_arguments[:seed] || 100
          log_info "--record switch found. Recording will be started with a seed value of #{seed} (--seed)."
          start_recording seed.to_i
        elsif cli_arguments.keys.include? :replay
          if Kernel.global_tick_count >=0
            @argsv_processed = true
            replay = cli_arguments[:replay] || "last_replay.txt"
            log_info "--replay switch found. Replay will be started using file [#{replay}] (--replay FILENAME) with replay speed [#{@simulation_speed}] (--speed SPEED)."
            start_replay replay, speed: @simulation_speed
          end
        elsif cli_arguments.keys.include? :eval
          @argsv_processed = true
          path = cli_arguments[:eval]
          log_info "--eval switch found. Executing code inside of #{path} before first tick executes.", subsystem="Engine"
          begin
            raise "File does not exist: #{path}" unless read_file path
            @eval_path = path
          rescue Exception => e
            log e
          end

          if cli_arguments.keys.include? "no-tick".to_sym
            log_info "--no-tick switch found. Exiting.", subsystem="Engine"
            @no_tick = true
          end
        elsif cli_arguments.keys.include? :test
          @argsv_processed = true
          path = cli_arguments[:test]
          log_info "--test switch found. Executing code inside of =#{path}=."
          begin
            raise "File does not exist: #{path}" unless read_file path
            @test_path = path
          rescue Exception => e
            log e
          end

          @no_tick = true
        else
          @argsv_processed = true
        end
      end

      def tick_argv
        tick_argv_eval_path
        tick_argv_test_path
      end

      def quit_after_startup_eval?
        return false unless @no_tick
        # @scheduled_callbacks is used by unit testing http
        # it keeps the app from exiting until all scheduled
        # callbacks have been processed (eg we need to keep the
        # game running for unit tests around http which are async)

        # it's also useful for debugging
        last_scheduled_proc = @scheduled_callbacks.keys.sort[-1]
        return true unless last_scheduled_proc
        return Kernel.tick_count > ((last_scheduled_proc || 0) + 1)
      end

      def tick_argv_eval_path
        return if !@eval_path

        if !reload_list_history[@eval_path]
          require @eval_path
          return
        end

        file_history = reload_list_history[@eval_path][:history]
        eval_path_loaded = file_history.find { |entry| entry[:event] == :reload_completed }

        return if !eval_path_loaded

        request_quit if quit_after_startup_eval?

        @eval_path = nil
      end

      def tick_argv_test_path
        return if !@test_path

        if !reload_list_history[@test_path]
          require @test_path
          return
        end

        file_history = reload_list_history[@test_path][:history]
        test_path_loaded = file_history.find { |entry| entry[:event] == :reload_completed }

        return if !test_path_loaded

        $tests.start
        request_quit
      end
    end
  end
end
