# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# assert.rb has been released under MIT (*only this file*).

module GTK
=begin
This is a tiny assertion api for the unit testing portion of Game Toolkit.

@example

1. Create a file called tests.rb under mygame.
2. Any method that begins with the word test_ will be considered a test.

def test_this_works args, assert
  assert.equal! 1, 1
end

3. To run a test, save the file while the game is running.

@example

To add an assertion open up this class and write:

class Assert
  def custom_assertion actual, expected, message = nil
    # this tells Game Toolkit that an assertion was performed (so that the test isn't marked inconclusive).
    @assertion_performed = true

    # perform your custom logic here and raise an exception to denote a failure.

    raise "Some Error. #{message}."
  end
end
=end
  class Assert
    attr :assertion_performed

=begin
Use this if you are throwing your own exceptions and you want to mark the tests as ran (so that it wont be marked as inconclusive).
=end
    def ok!
      @assertion_performed = true
    end

=begin
Assert if a value is a truthy value. All assert methods take an optional final parameter that is the message to display to the user.

@example

def test_does_this_work args, assert
  some_result = Person.new
  assert.true! some_result
  # OR
  assert.true! some_result, "Person was not created."
end
=end
    def true! value, message = nil
      @assertion_performed = true
      if !value
        message = "#{value} was not truthy.\n#{message}"
        raise "#{message}"
      end
      nil
    end

=begin
Assert if a value is a falsey value.

@example

def test_does_this_work args, assert
  some_result = nil
  assert.false! some_result
end
=end
    def false! value, message = nil
      @assertion_performed = true
      if value
        message = "#{value} was not falsey.\n#{message}"
        raise message
      end
      nil
    end

=begin
Assert if two values are equal.

@example

def test_does_this_work args, assert
  a = 1
  b = 1
  assert.equal! a, b
end
=end
    def equal! actual, expected, message = nil
      @assertion_performed = true
      if actual != expected
        actual_string = "#{actual}#{actual.nil? ? " (nil) " : " " }".strip
        message = "actual:\n#{actual_string}\n\ndid not equal\n\nexpected:\n#{expected}\n#{message}"
        raise message
      end
      nil
    end

    def not_equal! actual, expected, message = nil
      @assertion_performed = true
      if actual == expected
        actual_string = "#{actual}#{actual.nil? ? " (nil) " : " " }".strip
        message = "actual:\n#{actual_string}\n\nequaled\n\nexpected:\n#{expected}\n#{message}"
        raise message
      end
      nil
    end

=begin
Assert if a value is explicitly nil (not false).

@example

def test_does_this_work args, assert
  a = nil
  b = false
  assert.nil! a # this will pass
  assert.nil! b # this will throw an exception.
end
=end
    def nil! value, message = nil
      @assertion_performed = true
      if !value.nil?
        message = "#{value} was supposed to be nil, but wasn't.\n#{message}"
        raise message
      end
      nil
    end
  end
end
