# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# docs.rb has been released under MIT (*only this file*).

module GTK
  class Docs
    def map_with_ys
      puts <<-S
*  Numeric#map_with_ys
Numeric#map_with_ys is a helper method that is useful for working with coordinates
or rows with columns. Here is an example usage.

Assume you have a grid with 10 rows (xs) and 5 columns (ys). You can generate
an array of hashes with the following form:

#+begin_src
[
  { x: 0, y: 0, some_data: "A" },
  { x: 0, y: 1, some_data: "A" },
  { x: 0, y: 2, some_data: "A" },
...
  { x: 9, y: 4, some_data: "A" },
]
#+end_src

Using the following code:

#+begin_src ruby
array_of_hashes = 10.map_with_ys 5 do |x, y|
 { x: x, y: y, some_data: "A" }
end

Take a look at the "hexagon grid" sample app for a real world usage of
this method.
#+end_src
S
    end

    def method_missing m, *args
      puts <<-S
* DOCUMENTATION MISSING:
It looks like docs are missing for :#{m}. Let the @dragonborne know about it in the Discord channel: http://discord.dragonruby.org.
S
    end
  end
end
