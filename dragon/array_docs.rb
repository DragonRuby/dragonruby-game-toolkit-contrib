# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# array_docs.rb has been released under MIT (*only this file*).

module ArrayDocs
  def docs_method_sort_order
    [
      :docs_class,
      :docs_map,
      :docs_each,
      :docs_reject_nil,
      :docs_reject_false,
      :docs_product,
      :docs_map_2d,
      :docs_include_any?,
      :docs_any_intersect_rect?
    ]
  end

  def docs_include_any?
    <<-S
* DOCS: ~Array#include_any?~

Given a collection of items, the function will return
~true~ if any of ~self~'s items exists in the collection of items passed in:

S
  end

  def docs_class
    <<-S
* DOCS: ~Array~

The Array class has been extend to provide methods that
will help in common game development tasks. Array is one of the most
powerful classes in Ruby and a very fundamental component of Game Toolkit.

S
  end

  def docs_reject_nil
    <<-S
* DOCS: ~Array#reject_nil~

Returns an ~Enumerable~ rejecting items that are ~nil~, this is an alias
for ~Array#compact~:

#+begin_src
  repl do
    a = [1, nil, 4, false, :a]
    puts a.reject_nil
    # => [1, 4, false, :a]
    puts a.compact
    # => [1, 4, false, :a]
  end
#+end_src

S
  end

  def docs_reject_false
    <<-S
* DOCS: ~Array#reject_false~

Returns an `Enumerable` rejecting items that are `nil` or `false`.

#+begin_src
  repl do
    a = [1, nil, 4, false, :a]
    puts a.reject_false
    # => [1, 4, :a]
  end
#+end_src

S
  end

  def docs_product
    <<-S
* DOCS: ~Array#product~

Returns all combinations of values between two arrays.

Here are some examples of using ~product~. Paste the
following code at the bottom of main.rb and save
the file to see the results:

#+begin_src
  repl do
    a = [0, 1]
    puts a.product
    # => [[0, 0], [0, 1], [1, 0], [1, 1]]
  end
#+end_src

#+begin_src
  repl do
    a = [ 0,  1]
    b = [:a, :b]
    puts a.product b
    # => [[0, :a], [0, :b], [1, :a], [1, :b]]
  end
#+end_src

S
  end

  def docs_map_2d
    <<-S
* DOCS: ~Array#map_2d~

Assuming the array is an array of arrays, Given a block, each 2D array index invoked against the block.
A 2D array is a common way to store data/layout for a stage.

#+begin_src
  repl do
    stage = [
      [:enemy, :empty, :player],
      [:empty, :empty,  :empty],
      [:enemy, :empty,  :enemy],
    ]

    occupied_tiles = stage.map_2d do |row, col, tile|
      if tile == :empty
        nil
      else
        [row, col, tile]
      end
    end.reject_nil

    puts "Stage:"
    puts stage

    puts "Occupied Tiles"
    puts occupied_tiles
  end
#+end_src

S
  end

  def docs_any_intersect_rect?
    <<-S
* DOCS: ~Array#any_intersect_rect?~

Assuming the array contains objects that respond to ~left~, ~right~, ~top~, ~bottom~,
this method returns ~true~ if any of the elements within
the array intersect the object being passed in. You are given an optional
parameter called ~tolerance~ which informs how close to the other rectangles
the elements need to be for it to be considered intersecting.

The default tolerance is set to ~0.1~, which means that the primitives are not
considered intersecting unless they are overlapping by more than ~0.1~.

#+begin_src
  repl do
    # Here is a player class that has position and implement
    # the ~attr_rect~ contract.
    class Player
      attr_rect
      attr_accessor :x, :y, :w, :h

      def initialize x, y, w, h
        @x = x
        @y = y
        @w = w
        @h = h
      end

      def serialize
        { x: @x, y: @y, w: @w, h: @h }
      end

      def inspect
        "\#{serialize}"
      end

      def to_s
        "\#{serialize}"
      end
    end

    # Here is a definition of two walls.
    walls = [
       [10, 10, 10, 10],
       { x: 20, y: 20, w: 10, h: 10 },
     ]

    # Display the walls.
    puts "Walls."
    puts walls
    puts ""

    # Check any_intersect_rect? on player
    player = Player.new 30, 20, 10, 10
    puts "Is Player \#{player} touching wall?"
    puts (walls.any_intersect_rect? player)
    # => false
    # The value is false because of the default tolerance is 0.1.
    # The overlap of the player rect and any of the wall rects is
    # less than 0.1 (for those that intersect).
    puts ""

    player = Player.new 9, 10, 10, 10
    puts "Is Player \#{player} touching wall?"
    puts (walls.any_intersect_rect? player)
    # => true
    puts ""
  end
#+end_src

S
  end

  def docs_map
    <<-S
* DOCS: ~Array#map~

The function given a block returns a new ~Enumerable~ of values.

Example of using ~Array#map~ in conjunction with ~args.state~ and
~args.outputs.sprites~ to render sprites to the screen.

#+begin_src
  def tick args
    # define the colors of the rainbow in ~args.state~
    # as an ~Array~ of ~Hash~es with :order and :name.
    # :order will be used to determine render location
    #  and :name will be used to determine sprite path.
    args.state.rainbow_colors ||= [
      { order: 0, name: :red    },
      { order: 1, name: :orange },
      { order: 2, name: :yellow },
      { order: 3, name: :green  },
      { order: 4, name: :blue   },
      { order: 5, name: :indigo },
      { order: 6, name: :violet },
    ]

    # render sprites diagonally to the screen
    # with a width and height of 50.
    args.outputs
        .sprites << args.state
                        .rainbow_colors
                        .map do |color| # <-- ~Array#map~ usage
                          [
                            color[:order] * 50,
                            color[:order] * 50,
                            50,
                            50,
                            "sprites/square-\#{color[:name]}.png"
                          ]
                        end
  end
#+end_src

S
  end

  def docs_each
    <<-S
* DOCS: ~Array#each~

The function, given a block, invokes the block for each item in the
~Array~. ~Array#each~ is synonymous to foreach constructs in other languages.

Example of using ~Array#each~ in conjunction with ~args.state~ and
~args.outputs.sprites~ to render sprites to the screen:

#+begin_src
  def tick args
    # define the colors of the rainbow in ~args.state~
    # as an ~Array~ of ~Hash~es with :order and :name.
    # :order will be used to determine render location
    #  and :name will be used to determine sprite path.
    args.state.rainbow_colors ||= [
      { order: 0, name: :red    },
      { order: 1, name: :orange },
      { order: 2, name: :yellow },
      { order: 3, name: :green  },
      { order: 4, name: :blue   },
      { order: 5, name: :indigo },
      { order: 6, name: :violet },
    ]

    # render sprites diagonally to the screen
    # with a width and height of 50.
    args.state
        .rainbow_colors
        .map do |color| # <-- ~Array#each~ usage
          args.outputs.sprites << [
            color[:order] * 50,
            color[:order] * 50,
            50,
            50,
            "sprites/square-\#{color[:name]}.png"
          ]
        end
  end
#+end_src

S
  end
end

class Array
  extend Docs
  extend ArrayDocs
end
