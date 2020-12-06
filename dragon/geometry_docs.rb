# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# geometry_docs.rb has been released under MIT (*only this file*).

module GeometryDocs
  def docs_method_sort_order
    [:docs_class, :docs_scale_rect]
  end

  def docs_class
    <<-S
* DOCS: ~Geometry~

The Geometry module contains methods for calculations that are frequently used in game development.

S
  end

  def docs_scale_rect
    <<-S
* DOCS: ~GTK::Geometry#scale_rect~

Given an array with 4 elements representing a rect [x, y, w, h], this function returns a scaled rect. It accepts three arguments:

~ratio~: the ratio by which to scale the rect. A ratio of 2 will double the dimensions of the rect while a ratio of 0.5 will halve its dimensions. 

~anchor_x~ and ~anchor_y~ specify the point within the rect from which to resize it. Setting both to 0 will affect the width and height of the rect, leaving x and y unchanged. Setting both to 0.5 will scale all sides of the rect proportionally from the center.

The ~scale_rect~ method can be applied directly to a sprite or other primitives. See CHEATSHEET: How to Scale a Sprite.

#+begin_src ruby
  def tick args
    #       x,   y,   w,   h
    my_rect = [100, 100, 200, 200]

    # halve the dimensions of the rect: 
    #                             ratio, anchor_x, anchor_y
    new_rect = my_rect.scale_rect(0.5,   0.5,      0.5)
  
    puts new_rect # => [150.0, 150.0, 100.0, 100.0]
  end
#+end_src

S
  end
end

module Geometry
  extend Docs
  extend GeometryDocs
end
