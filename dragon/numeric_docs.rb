# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# numeric_docs.rb has been released under MIT (*only this file*).

module NumericDocs
  def docs_method_sort_order
    [
      :docs_frame_index,
      :docs_elapsed_time,
      :docs_elapsed?,
      :docs_new?
    ]
  end

  def docs_frame_index
    <<-S
* DOCS: ~Numeric#frame_index~

This function is helpful for determining the index of frame-by-frame
  sprite animation. The numeric value ~self~ represents the moment the
  animation started.

~frame_index~ takes three additional parameters:

- How many frames exist in the sprite animation.
- How long to hold each animation for.
- Whether the animation should repeat.

~frame_index~ will return ~nil~ if the time for the animation is out
of bounds of the parameter specification.

Example using variables:

#+begin_src ruby
  def tick args
    start_looping_at = 0
    number_of_sprites = 6
    number_of_frames_to_show_each_sprite = 4
    does_sprite_loop = true

    sprite_index =
      start_looping_at.frame_index number_of_sprites,
                                   number_of_frames_to_show_each_sprite,
                                   does_sprite_loop

    sprite_index ||= 0

    args.outputs.sprites << [
      640 - 50,
      360 - 50,
      100,
      100,
      "sprites/dragon-\#{sprite_index}.png"
    ]
  end
#+end_src

Example using named parameters:

#+begin_src ruby
  def tick args
    start_looping_at = 0

    sprite_index =
      start_looping_at.frame_index count: 6,
                                   hold_for: 4,
                                   repeat: true,
                                   tick_count_override: args.state.tick_count

    sprite_index ||= 0

    args.outputs.sprites << [
      640 - 50,
      360 - 50,
      100,
      100,
      "sprites/dragon-\#{sprite_index}.png"
    ]
  end
#+end_src

S
  end

  def docs_new?
    <<-S
* DOCS: ~Numeric#created?~
Returns true if ~Numeric#elapsed_time == 0~. Essentially communicating that
number is equal to the current frame.

Example usage:

#+begin_src ruby
  def tick args
    args.state.box_queue ||= []

    if args.state.box_queue.empty?
      args.state.box_queue << { name: :red,
                                create_at: args.state.tick_count + 60 }
    end

    boxes_to_spawn_this_frame = args.state
                                    .box_queue
                                    .find_all { |b| b[:create_at].new? }

    boxes_to_spawn_this_frame.each { |b| puts "box \#{b} was new? on \#{args.state.tick_count}." }

    args.state.box_queue -= boxes_to_spawn_this_frame
  end
#+end_src
S
  end

  def docs_elapsed?
    <<-S
* DOCS: ~Numeric#elapsed?~
Returns true if ~Numeric#elapsed_time~ is greater than the number. An optional parameter can be
passed into ~elapsed?~ which is added to the number before evaluating whether ~elapsed?~ is true.

Example usage (no optional parameter):

#+begin_src ruby
  def tick args
    args.state.box_queue ||= []

    if args.state.box_queue.empty?
      args.state.box_queue << { name: :red,
                                destroy_at: args.state.tick_count + 60 }
      args.state.box_queue << { name: :green,
                                destroy_at: args.state.tick_count + 60 }
      args.state.box_queue << { name: :blue,
                                destroy_at: args.state.tick_count + 120 }
    end

    boxes_to_destroy = args.state
                           .box_queue
                           .find_all { |b| b[:destroy_at].elapsed? }

    if !boxes_to_destroy.empty?
      puts "boxes to destroy count: \#{boxes_to_destroy.length}"
    end

    boxes_to_destroy.each { |b| puts "box \#{b} was elapsed? on \#{args.state.tick_count}." }

    args.state.box_queue -= boxes_to_destroy
  end
#+end_src

Example usage (with optional parameter):

#+begin_src ruby
  def tick args
    args.state.box_queue ||= []

    if args.state.box_queue.empty?
      args.state.box_queue << { name: :red,
                                create_at: args.state.tick_count + 120,
                                lifespan: 60 }
      args.state.box_queue << { name: :green,
                                create_at: args.state.tick_count + 120,
                                lifespan: 60 }
      args.state.box_queue << { name: :blue,
                                create_at: args.state.tick_count + 120,
                                lifespan: 120 }
    end

    # lifespan is passed in as a parameter to ~elapsed?~
    boxes_to_destroy = args.state
                           .box_queue
                           .find_all { |b| b[:create_at].elapsed? b[:lifespan] }

    if !boxes_to_destroy.empty?
      puts "boxes to destroy count: \#{boxes_to_destroy.length}"
    end

    boxes_to_destroy.each { |b| puts "box \#{b} was elapsed? on \#{args.state.tick_count}." }

    args.state.box_queue -= boxes_to_destroy
  end
#+end_src

S
  end

  def docs_elapsed_time
    <<-S
* DOCS: ~Numeric#elapsed_time~
For a given number, the elapsed frames since that number is returned.
`Kernel.tick_count` is used to determine how many frames have elapsed.
An optional numeric argument can be passed in which will be used instead
of `Kernel.tick_count`.

Here is an example of how elapsed_time can be used.

#+begin_src ruby
  def tick args
    args.state.last_click_at ||= 0

    # record when a mouse click occurs
    if args.inputs.mouse.click
      args.state.last_click_at = args.state.tick_count
    end

    # Use Numeric#elapsed_time to determine how long it's been
    if args.state.last_click_at.elapsed_time > 120
      args.outputs.labels << [10, 710, "It has been over 2 seconds since the mouse was clicked."]
    end
  end
#+end_src

And here is an example where the override parameter is passed in:

#+begin_src ruby
  def tick args
    args.state.last_click_at ||= 0

    # create a state variable that tracks time at half the speed of args.state.tick_count
    args.state.simulation_tick = args.state.tick_count.idiv 2

    # record when a mouse click occurs
    if args.inputs.mouse.click
      args.state.last_click_at = args.state.simulation_tick
    end

    # Use Numeric#elapsed_time to determine how long it's been
    if (args.state.last_click_at.elapsed_time args.state.simulation_tick) > 120
      args.outputs.labels << [10, 710, "It has been over 4 seconds since the mouse was clicked."]
    end
  end
#+end_src

S
  end
end

class Numeric
  extend Docs
  extend NumericDocs
end
