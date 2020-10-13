# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# trace.rb has been released under MIT (*only this file*).

# Contributors outside of DragonRuby who also hold Copyright:
# - Dan Healy: https://github.com/danhealy

module GTK
  module Trace
    IGNORED_METHODS = [
      :define_singleton_method, :raise_immediately, :instance_of?,
      :raise_with_caller, :initialize_copy, :class_defined?,
      :instance_variable_get, :format, :purge_class, :instance_variable_defined?,
      :metadata_object_id, :instance_variable_set, :__printstr__,
      :instance_variables, :is_a?, :p, :kind_of?, :==, :log_once,
      :protected_methods, :log_once_info, :private_methods, :open,
      :!=, :initialize, :object_id, :Hash, :methods, :tick, :!,
      :respond_to?, :yield_self, :send, :instance_eval, :then,
      :__method__, :__send__, :log_print, :dig, :itself, :log_info,
      :remove_instance_variable, :raise, :public_methods, :instance_exec,
      :gets, :local_variables, :tap, :__id__, :class, :singleton_class,
      :block_given?, :_inspect, :puts, :global_variables, :getc, :iterator?,
      :hash, :to_enum, :printf, :frozen?, :print, :original_puts,
      :srand, :freeze, :rand, :extend, :eql?, :equal?, :sprintf, :clone,
      :dup, :to_s, :primitive_determined?, :inspect, :primitive?, :help,
      :__object_methods__, :proc, :__custom_object_methods__, :Float, :enum_for,
      :__supports_ivars__?, :nil?, :fast_rand, :or, :and,
      :__caller_without_noise__, :__gtk_ruby_string_contains_source_file_path__?,
      :__pretty_print_exception__, :__gtk_ruby_source_files__,
      :String, :log, :Array, :putsc, :Integer, :===, :here,
      :raise_error_with_kind_of_okay_message, :better_instance_information,
      :lambda, :fail, :method_missing, :__case_eqq, :caller,
      :raise_method_missing_better_error, :require, :singleton_methods,
      :!~, :loop, :numeric_or_default, :`, :state, :inputs, :outputs, "args=".to_sym,
      :grid, :gtk, :dragon, :args, :passes, :tick, :grep_source, :grep_source_file,
      :numeric_or_default, :f_or_default, :s_or_default, :i_or_default,
      :comment, :primitive_marker, :xrepl, :repl
    ]

    def self.traced_classes
      @traced_classes ||= []
      @traced_classes
    end

    def self.mark_class_as_traced! klass
      @traced_classes << klass
    end

    def self.untrace_classes!
      traced_classes.each do |klass|
        klass.class_eval do
          all_methods = klass.instance_methods false
          if klass.instance_methods.respond_to?(:__trace_call_depth__)
            undef_method :__trace_call_depth__
          end

          GTK::Trace.filter_methods_to_trace(all_methods).each do |m|
            original_method_name = m
            trace_method_name = GTK::Trace.trace_method_name_for m
            if klass.instance_methods.include? trace_method_name
              alias_method m, trace_method_name
            end
          end
        end
      end
      $last_method_traced = nil
      @traced_classes.clear
      $trace_enabled = false
      if !$gtk.production
        $gtk.write_file_root 'logs/trace.txt', "Add trace!(SOMEOBJECT) to the top of ~tick~ and this file will be populated with invocation information.\n"
      end
    end

    def self.trace_method_name_for m
      "__trace_original_#{m}__".to_sym
    end

    def self.original_method_name_for m
      return m unless m.to_s.start_with?("__trace_original_") && m.to_s.end_with?("__")
      m[16..-3]
    end

    def self.filter_methods_to_trace methods
      methods.reject { |m| m.start_with? "__trace_" }.reject { |m| IGNORED_METHODS.include? m }
    end

    def self.trace_times_string
      str = []
      $trace_performance.sort_by {|method_name, times| -times[:avg] }.each do |method_name, times|
        str << "#{method_name}: #{times[:sum].round(2)}/#{times[:count]} #{times[:min]}ms min, #{times[:avg].round(2)}ms avg, #{times[:max]}ms max"
      end
      str.join("\n")
    end

    def self.flush_trace pad_with_newline = false
      $trace_puts ||= []
      puts "(Trace info flushed!)"
      if $trace_puts.length > 0
        text = $trace_puts.join("").strip + "\n" + self.trace_times_string + "\n"
        if pad_with_newline
          $gtk.append_file_root 'logs/trace.txt', "\n" + text.strip
        else
          $gtk.append_file_root 'logs/trace.txt', text.strip
        end
      end
      $trace_puts.clear
    end

    # @gtk
    def self.trace! instance = nil
      $trace_history ||= []
      $trace_enabled = true
      $trace_call_depth ||=0
      $trace_performance = Hash.new {|h,k|
        h[k] = {
          min:   100000,
          max:   0,
          avg:   0,
          sum:   0,
          count: 0
        }
      }
      flush_trace
      instance = $top_level unless instance
      return if Trace.traced_classes.include? instance.class
      all_methods = instance.class.instance_methods false
      instance.class.class_eval do
        attr_accessor :__trace_call_depth__ unless instance.class.instance_methods.include?(:__trace_call_depth__)
        GTK::Trace.filter_methods_to_trace(all_methods).each do |m|
          original_method_name = m
          trace_method_name = GTK::Trace.trace_method_name_for m
          alias_method trace_method_name, m
          $trace_puts << "Tracing #{m} on #{instance.class}.\n"
          define_method(m) do |*args|
            instance.__trace_call_depth__ ||= 0
            tab_width = " " * (instance.__trace_call_depth__ * 8)
            instance.__trace_call_depth__ += 1
            $trace_call_depth = instance.__trace_call_depth__
            parameters = "#{args}"[1..-2]

            $trace_puts << "\n  #{tab_width}#{m}(#{parameters})"

            execution_time = Time.new

            $last_method_traced = trace_method_name
            $trace_history << [m, parameters]

            result = send(trace_method_name, *args)

            class_m = "#{instance.class}##{m}"
            completion_time = ((Time.new - execution_time).to_f * 1000).round(2)
            $trace_performance[class_m][:min] = [$trace_performance[class_m][:min], completion_time].min
            $trace_performance[class_m][:max] = [$trace_performance[class_m][:max], completion_time].max
            $trace_performance[class_m][:count] += 1
            $trace_performance[class_m][:sum] += completion_time
            $trace_performance[class_m][:avg] = $trace_performance[class_m][:sum].fdiv($trace_performance[class_m][:count])

            instance.__trace_call_depth__ -= 1
            instance.__trace_call_depth__ = instance.__trace_call_depth__.greater 0
            $trace_puts << "\n #{tab_width} #{completion_time > 10 ? '!!! ' : ''}#{completion_time}ms success: #{m}"
            if instance.__trace_call_depth__ == 0
              $trace_puts << "\n"
              $trace_history.clear
            end
            result
          rescue Exception => e
            instance.__trace_call_depth__ -= 1
            instance.__trace_call_depth__ = instance.__trace_call_depth__.greater 0
            $trace_puts << "\n #{tab_width} failed: #{m}"
            if instance.__trace_call_depth__ == 0
              $trace_puts << "\n #{tab_width}         #{e}"
              $trace_puts << "\n"
            end
            $trace_call_depth = 0
            GTK::Trace.flush_trace true
            raise e
          end
        end
      end
      mark_class_as_traced! instance.class
    end
  end
end
