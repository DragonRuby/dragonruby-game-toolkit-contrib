# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# auto_test.rb has been released under MIT (*only this file*).

module GTK
  class Runtime
    module AutoTest
      def tick_auto_test
        return if @production
        return if @load_status != :ready
        return if (Kernel.global_tick_count % 60) != 0
        auto_test_initialize
        tick_auto_test_discover_tests
        tick_auto_test_run_changed
        tick_auto_test_reset_all_mtimes
      end

      def auto_test_initialize
        return if @auto_test_initialized
        @auto_test_files = {}
        @required_files.find_all { |f| f.end_with? "tests.rb" }
                       .each do |f|
                         log "* INFO: Test =#{f}= found and added to hotload file list."
                         @auto_test_files[f] = {
                           current: @ffi_file.mtime(f),
                           last: @ffi_file.mtime(f)
                         }
                       end
        @auto_test_initialized = true
      end

      def tick_auto_test_run_changed
        @auto_test_files.each do |k, v|
          v.current = @ffi_file.mtime k
        end

        changed_tests = @auto_test_files.any? { |k, v| v[:current] != v[:last] }
        auto_test_run_tests if changed_tests
      end

      def auto_test_run_tests
        $tests.start
        $tests.clear_summary
      end

      def tick_auto_test_reset_all_mtimes
        @auto_test_files.each do |k, v|
          v.current = @ffi_file.mtime k
          v.last = @ffi_file.mtime k
        end
      end

      def tick_auto_test_discover_tests
        test_files = list_files "tests"
        test_files.each do |f|
          test_path = "tests/#{f}"
          if !@required_files.include? test_path
            if f.end_with? "tests.rb"
              log "* INFO: Test =#{test_path}= found and added to hotload file list."
              @required_files << test_path
              @auto_test_files[test_path] = { current: @ffi_file.mtime(test_path), last: @ffi_file.mtime(test_path) }
            end
          end
        end
      end
    end # end autotest
  end # end runtime
end # end gtk
