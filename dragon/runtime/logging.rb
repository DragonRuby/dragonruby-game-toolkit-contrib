# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# logging.rb has been released under MIT (*only this file*).

module GTK
  module Logging
    attr_accessor :__pending_log_entry_count__

    def log_spam str, subsystem = nil
      __log__ subsystem, 0, str
    end

    def log_debug str, subsystem = nil
      __log__ subsystem, 1, str
    end

    def log_info str, subsystem = nil
      __log__ subsystem, 2, str
    end

    def log_warn str, subsystem = nil
      __log__ subsystem, 3, str
    end

    def log_error str, subsystem = nil
      __log__ subsystem, 4, str
    end

    def log_unfiltered str, subsystem = nil
      __log__ subsystem, 0x7FFFFFFE, str
    end

    def __log__ subsystem, log_enum, str
      @__pending_log_entry_count__ ||= 0
      @__pending_log_entry_count__ += 1
      if @__pending_log_entry_count__ > 100
        flush_logs
      end
      str = str.to_s.gsub "\000", ""
      @ffi_misc.log subsystem, log_enum, str
    end

    def log obj, sender = nil, subsystem=nil
      if sender == Log && @log_level == :on
        log_info(obj, subsystem)
      elsif !sender
        log_info(obj, subsystem)
      end
   end
  end
end
