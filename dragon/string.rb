# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# string.rb has been released under MIT (*only this file*).

class String
  include ValueType

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

  def self.wrapped_lines(string, length)
    string.each_line.map do |line|
      output_lines = []
      line = line.rstrip

      if line.length < length
        output_lines << line + "\n"
      else
        words = line.split ' '
        current_line = words[0]

        words[1..-1].each do |word|
          if (current_line + " " + word).length > length
            output_lines << current_line + "\n"
            current_line = word
          else
            current_line += " " + word
          end
        end

        output_lines << current_line + "\n" if current_line
      end

      output_lines
    end.flatten
  end

  def wrapped_lines length
    String.wrapped_lines self, length
  end

  def wrap length
    wrapped_lines(length).join.rstrip
  end

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

  # !!! FIXME: Strange bug where garbage bytes are still left over after a strip for a string.
  alias_method :__original_strip__, :strip unless String.instance_methods.include?(:__original_strip__)

  # might not be needed given: 78ed497c9ae5fb10b8fe084b5cc73c9e6ad160d6
  def strip
    "#{__original_strip__}"
  end

  def indent count, indent_char: "  ", pad_line_with_space: false
    count = 0 if count < 0
    spaces = indent_char * count
    spaces += " " if pad_line_with_space
    self.each_line.map do |l|
      "#{spaces}#{l}"
    end.join
  end

  def ljust(count, padstr = " ")
    if self.length >= count
      self
    else
      self + (padstr * (count - self.length))
    end
  end

  def rjust(count, padstr = " ")
    if self.length >= count
      self
    else
      (padstr * (count - self.length)) + self
    end
  end

  def self.line_anchors line_count
    line_count = line_count.to_i
    results = []
    if line_count % 2 == 0
      above_below_count = (line_count).idiv(2)
      above_below_count.times do |i|
        results << 1.0 - (above_below_count - i) * 1.0
      end
      above_below_count.times do |i|
        results << 0.0 + (i + 1) * 1.0
      end
      return results
    else
      above_below_count = (line_count - 1).idiv(2)
      above_below_count.times do |i|
        results << 0.5 - (above_below_count - i) * 1.0
      end
      results << 0.5
      above_below_count.times do |i|
        results << 0.5 + (i + 1) * 1.0
      end
      return results
    end
  end
end
