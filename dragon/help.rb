# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# help.rb has been released under MIT (*only this file*).

module GTK
  class Help
    def self.primitive_contract primitive_name
      if primitive_name == :label
        label_contract
      elsif primitive_name == :solid
        solid_border_contract
      elsif primitive_name == :border
        solid_border_contract
      elsif primitive_name == :sprite
        sprite_contract
      else
        help_text = "No contract found for primitive #{primitive_name}. The supported primitives are :label, :solid, :border, :sprite."
      end
    end

    def self.label_contract
      <<-S
* :label (if :primitive_marker returns :label)
** :x, :y, :text
** :size_enum
default: 0
negative value means smaller text
positive value means larger text
** :alignment_enum default: 0
default: 0
0: left aligned, 1: center aligned, 2: right aligned
** :r, :g, :b, :a
default: 0's for rgb and 255 for a
** :font
default nil
path to ttf file
S
    end

    def self.solid_border_contract
      <<-S
* :solid, :border (if :primitive_marker returns :solid or :border)
** :x, :y, :w, :h, :r, :g, :b, :a
S
    end

    def self.label_contract
      <<-S
* :line (if :primitive_marker returns :line)
** :x, :y, :x2, :y2, :r, :g, :b, :a
S
    end

    def self.sprite_contract
      <<-S
* :sprite (if :primitive_marker returns :sprite)
** :x, :y, :w, :h
** :angle, :angle_anchor_x, :angle_anchor_y
default for angle: 0 (0 to 360 degrees)
default for angle_anchor_(x|y): 0 (decimal value between 0 and 1.0, 0.5 means center)
** :r, :g, :b, :a
** :tile_x, :tile_y
default: 0, x, y offset for sprite to crop at
** :tile_w, :tile_h
default: -1, width and height of crop (-1 means full width and height)
** :flip_horizontally, :flip_vertically
default: falsey value
S
    end
  end
end
