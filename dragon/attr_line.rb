# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# attr_line.rb has been released under MIT (*only this file*).

module AttrLine
  attr_accessor :x, :y, :x2, :y2, :w, :h, :r, :g, :b, :a, :blendmode_enum

  def primitive_marker
    :line
  end

  def line
    self
  end

  def x1= value
    @x = value
  end

  def x1
    @x
  end

  def y1= value
    @y = value
  end

  def y1
    @y
  end
end

class Object
  def self.attr_line
    include AttrLine
  end

  def attr_line
    return if self.is_a? AttrLine
    self.class.include AttrLine
  end
end
