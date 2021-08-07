# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# string.rb has been released under MIT (*only this file*).

class String
  include ValueType

  def self.wrapped_lines_recur word, rest, length, aggregate
    if word.nil?
      return aggregate
    elsif rest[0].nil?
      aggregate << word + "\n"
      return aggregate
    elsif (word + " " + rest[0]).length > length
      aggregate << word + "\n"
      return wrapped_lines_recur rest[0], rest[1..-1], length, aggregate
    elsif (word + " " + rest[0]).length <= length
      next_word = (word + " " + rest[0])
      return wrapped_lines_recur next_word, rest[1..-1], length, aggregate
    else
      log <<-S
WARNING:
#{word} is too long to fit in length of #{length}.

S
      next_word = (word + " " + rest[0])
      return wrapped_lines_recur next_word, rest[1..-1], length, aggregate
    end
  end

  def char_byte
    return nil if self.length == 0
    c = self.each_char.first.bytes
    c = c.first if c.is_a? Enumerable
    c
  end

  def insert_character_at index, char
    t = each_char.to_a
    t = (t.insert index, char)
    t.join
  end

  def excluding_character_at index
    t = each_char.to_a
    t.delete_at index
    t.join
  end

  def excluding_last_character
    return "" if self.length <= 1
    return excluding_character_at(self.length - 1)
  end

  def end_with_bang?
    self[-1] == "!"
  end

  def without_ending_bang
    return self unless end_with_bang?
    self[0..-2]
  end

  def self.wrapped_lines string, length
    string.each_line.map do |l|
      l = l.rstrip
      if l.length < length
        l + "\n"
      else
        words = l.split ' '
        wrapped_lines_recur(words[0], words[1..-1], length, []).flatten
      end
    end.flatten
  end

  def wrapped_lines length
    String.wrapped_lines self, length
  end

  # @gtk
  def wrap length
    wrapped_lines(length).join.rstrip
  end

  # @gtk
  def multiline?
    include? "\n"
  end

  def indent_lines amount, char = " "
    self.each_line.each_with_index.map do |l, i|
      if i == 0
        l
      else
        char * amount + l
      end
    end.join
  end

  def quote
    "\"#{self}\""
  end

  def trim
    strip
  end

  def trim!
    strip!
  end

  def ltrim
    lstrip
  end

  def ltrim!
    lstrip!
  end

  def rtrim
    rstrip
  end

  def rtrim!
    rstrip!
  end

  def serialize
    self
  end
end
