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
                :source_x2, :source_y2, :source_x3, :source_y3, :x2, :y2, :x3, :y3,
                :anchor_x, :anchor_y, :r2, :g2, :b2, :a2, :r3, :g3, :b3, :a3,
                :scale_quality_enum, :blendmode

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

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end

  def serialize
    {
      x: @x,
      y: @y,
      w: @w,
      h: @h,
      path: @path,
      angle: @angle,
      a: @a,
      r: @r,
      g: @g,
      b: @b,
      tile_x: @tile_x,
      tile_y: @tile_y,
      tile_w: @tile_w,
      tile_h: @tile_h,
      flip_horizontally: @flip_horizontally,
      flip_vertically: @flip_vertically,
      angle_anchor_x: @angle_anchor_x,
      angle_anchor_y: @angle_anchor_y,
      id: @id,
      angle_x: @angle_x,
      angle_y: @angle_y,
      z: @z,
      source_x: @source_x,
      source_y: @source_y,
      source_w: @source_w,
      source_h: @source_h,
      blendmode_enum: @blendmode_enum,
      source_x2: @source_x2,
      source_y2: @source_y2,
      source_x3: @source_x3,
      source_y3: @source_y3,
      x2: @x2,
      y2: @y2,
      x3: @x3,
      y3: @y3,
      anchor_x: @anchor_x,
      anchor_y: @anchor_y,
      r2: @r2,
      g2: @g2,
      b2: @b2,
      a2: @a2,
      r3: @r3,
      g3: @g3,
      b3: @b3,
      a3: @a3,
      scale_quality_enum: @scale_quality_enum,
      blendmode: @blendmode,
    }end
end

class Object
  def self.attr_sprite
    include AttrSprite
  end

  def attr_sprite
    return if self.is_a? AttrSprite
    self.class.include AttrSprite
  end

  def self.attr_rect
    include AttrRect
  end

  def attr_rect
    return if self.is_a? AttrRect
    self.class.include AttrRect
  end
end
