# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# process_argsv.rb has been released under MIT (*only this file*).

module GTK
  class Runtime
    module ProcessARGSV
      def process_argsv
        return if @argsv_processed
        @argsv_processed = true

        @simulation_speed = (cli_arguments[:speed] || "1").to_i
        @simulation_speed = @simulation_speed.abs
        @simulation_speed = 1 if @simulation_speed == 0

        if cli_arguments.keys.include? :record
          seed = cli_arguments[:seed] || 100
          log_info "--record switch found. Recording will be started with a seed value of #{seed} (--seed)."
          start_recording seed.to_i
        elsif cli_arguments.keys.include? :replay
          replay = cli_arguments[:replay] || "last_replay.txt"
          log_info "--replay switch found. Replay will be started using file [#{replay}] (--replay FILENAME) with replay speed [#{@simulation_speed}] (--speed SPEED)."
          start_replay replay, speed: @simulation_speed
        elsif cli_arguments.keys.include? :eval
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
          path = cli_arguments[:test]
          log_info "--test switch found. Executing code inside of =#{path}=."
          begin
            raise "File does not exist: #{path}" unless read_file path
            @test_path = path
          rescue Exception => e
            log e
          end

          @no_tick = true
        end
      end
    end
  end
end
