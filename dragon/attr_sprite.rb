# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# attr_sprite.rb has been released under MIT (*only this file*).

# @private
module AttrRect
  include GTK::Geometry

  def left
    (@x || self.x)
  end

  def right
    (@x || self.x) + (@w || self.w)
  end

  def bottom
    (@y || self.y)
  end

  def top
    (@y || self.y) + (@h || self.h)
  end

  def x1
    (@x || self.x)
  end

  def y1
    (@y || self.y)
  end
end

module AttrSprite
  include AttrRect

  attr_accessor :x, :y, :w, :h, :path, :angle, :a, :r, :g, :b, :tile_x,
                :tile_y, :tile_w, :tile_h, :flip_horizontally,
                :flip_vertically, :angle_anchor_x, :angle_anchor_y, :id,
                :angle_x, :angle_y, :z,
                :source_x, :source_y, :source_w, :source_h, :blendmode_enum,
                :source_x2, :source_y2, :source_x3, :source_y3, :x2, :y2, :x3, :y3

  def primitive_marker
    :sprite
  end

  def sprite
    self
  end

  def x1= value
    @x = value
  end

  def y1= value
    @y = value
  end
end
