# Copyright 2019 DragonRuby LLC
# MIT License
# attr_sprite.rb has been released under MIT (*only this file*).

# @private
module AttrRect
  def self.included(klass)
    klass.alias_method :left, :x
    klass.alias_method :bottom, :y
  end

  def right
    x + w
  end

  def top
    y + h
  end
end

module AttrSprite
  include GTK::Geometry

  attr_accessor :x, :y, :w, :h, :path, :angle, :a, :r, :g, :b, :tile_x,
                :tile_y, :tile_w, :tile_h, :flip_horizontally,
                :flip_vertically, :angle_anchor_x, :angle_anchor_y, :id,
                :source_x, :source_y, :source_w, :source_h

  include AttrRect

  def primitive_marker
    :sprite
  end

  def sprite
    self
  end

  alias_method :x1, :x
  alias_method :x1=, :x=
  alias_method :y1, :y
  alias_method :y1=, :y=
end
