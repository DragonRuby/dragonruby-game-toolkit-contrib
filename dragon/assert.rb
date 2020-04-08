# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# assert.rb has been released under MIT (*only this file*).

module GTK
  class Assert
    attr :assertion_performed

    def ok!
      @assertion_performed = true
    end

    def true! value, message = nil
      @assertion_performed = true
      if !value
        message = "#{value} was not truthy.\n#{message}"
        raise "#{message}"
      end
      nil
    end

    def false! value, message = nil
      @assertion_performed = true
      if value
        message = "#{value} was not falsey.\n#{message}"
        raise message
      end
      nil
    end

    def equal! actual, expected, message = nil
      @assertion_performed = true
      if actual != expected
        actual_string = "#{actual}#{actual.nil? ? " (nil) " : " " }".strip
        message = "actual: #{actual_string} did not equal expected: #{expected}.\n#{message}"
        raise message
      end
      nil
    end

    def nil! value, message = nil
      @assertion_performed = true
      if !value.nil?
        message = "#{value} was supposed to be nil, but wasn't.\n#{message}"
        raise message
      end
      nil
    end

    def raises! exception_class, message = nil
      @assertion_performed = true
      begin
        yield
      rescue exception_class
        return # Success
      rescue Exception => e
        raise "Expected #{exception_class.name} to be raised but instead #{e.class.name} was raised\n#{message}"
      else
        raise "Expected #{exception_class.name} to be raised but nothing was raised\n#{message}"
      end
    end
  end
end
