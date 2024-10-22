# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# numeric_docs.rb has been released under MIT (*only this file*).

module NumericDocs
  def docs_method_sort_order
    [
      :docs_class,
      :docs_frame_index,
      :docs_elapsed_time,
      :docs_elapsed?,
      :docs_to_sf,
      :docs_to_si
    ]
  end

  def docs_class
    <<-S
* ~Numeric~

The ~Numeric~ class has been extend to provide methods that
will help in common game development tasks.

S
  end

  def docs_frame_index
    <<-S
** ~frame_index~

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

Example using named parameters. The named parameters version allows you to
also specify a ~repeat_index~ which is useful if your animation has starting
frames that shouldn't be considered when looped:

#+begin_src ruby
  def tick args
    start_looping_at = 0

    sprite_index =
      start_looping_at.frame_index count: 6,
                                   hold_for: 4,
                                   repeat: true,
                                   repeat_index: 0,
                                   tick_count_override: Kernel.tick_count

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

The named parameter variant of ~frame_index~ is also available on ~Numeric~:

#+begin_src ruby
  def tick args
    sprite_index =
      Numeric.frame_index start_at: 0,
                          count: 6, # or frame_count: 6 (if both are provided frame_count will be used)
                          hold_for: 4,
                          repeat: true,
                          repeat_index: 0,
                          tick_count_override: Kernel.tick_count

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

Another example where ~frame_index~ is applied to a sprite sheet.

#+begin_src ruby
  def tick args
    index = Numeric.frame_index start_at: 0,
                                frame_count: 7,
                                repeat: true
    args.outputs.sprites << {
      x: 0,
      y: 0,
      w: 32,
      h: 32,
      source_x: 32 * index,
      source_y: 0,
      source_w: 32,
      source_h: 32,
      path: "sprites/misc/explosion-sheet.png"
    }
  end
#+end_src

S
  end

  def docs_new?
    <<-S
** ~new?~
Returns true if ~Numeric#elapsed_time == 0~. Essentially communicating that
number is equal to the current frame.

Example usage:

#+begin_src ruby
  def tick args
    args.state.box_queue ||= []

    if args.state.box_queue.empty?
      args.state.box_queue << { name: :red,
                                create_at: Kernel.tick_count + 60 }
    end

    boxes_to_spawn_this_frame = args.state
                                    .box_queue
                                    .find_all { |b| b[:create_at].new? }

    boxes_to_spawn_this_frame.each { |b| puts "box \#{b} was new? on \#{Kernel.tick_count}." }

    args.state.box_queue -= boxes_to_spawn_this_frame
  end
#+end_src
S
  end

  def docs_elapsed?
    <<-S
** ~elapsed?~
Returns true if ~Numeric#elapsed_time~ is greater than the number. An optional parameter can be
passed into ~elapsed?~ which is added to the number before evaluating whether ~elapsed?~ is true.

Example usage (no optional parameter):

#+begin_src ruby
  def tick args
    args.state.box_queue ||= []

    if args.state.box_queue.empty?
      args.state.box_queue << { name: :red,
                                destroy_at: Kernel.tick_count + 60 }
      args.state.box_queue << { name: :green,
                                destroy_at: Kernel.tick_count + 60 }
      args.state.box_queue << { name: :blue,
                                destroy_at: Kernel.tick_count + 120 }
    end

    boxes_to_destroy = args.state
                           .box_queue
                           .find_all { |b| b[:destroy_at].elapsed? }

    if !boxes_to_destroy.empty?
      puts "boxes to destroy count: \#{boxes_to_destroy.length}"
    end

    boxes_to_destroy.each { |b| puts "box \#{b} was elapsed? on \#{Kernel.tick_count}." }

    args.state.box_queue -= boxes_to_destroy
  end
#+end_src

Example usage (with optional parameter):

#+begin_src ruby
  def tick args
    args.state.box_queue ||= []

    if args.state.box_queue.empty?
      args.state.box_queue << { name: :red,
                                create_at: Kernel.tick_count + 120,
                                lifespan: 60 }
      args.state.box_queue << { name: :green,
                                create_at: Kernel.tick_count + 120,
                                lifespan: 60 }
      args.state.box_queue << { name: :blue,
                                create_at: Kernel.tick_count + 120,
                                lifespan: 120 }
    end

    # lifespan is passed in as a parameter to ~elapsed?~
    boxes_to_destroy = args.state
                           .box_queue
                           .find_all { |b| b[:create_at].elapsed? b[:lifespan] }

    if !boxes_to_destroy.empty?
      puts "boxes to destroy count: \#{boxes_to_destroy.length}"
    end

    boxes_to_destroy.each { |b| puts "box \#{b} was elapsed? on \#{Kernel.tick_count}." }

    args.state.box_queue -= boxes_to_destroy
  end
#+end_src

S
  end

  def docs_to_sf
    <<-S
** ~to_sf~
Returns a "string float" representation of a number with two decimal places. eg: ~5.8778~ will be shown as ~5.88~.
S
  end

  def docs_to_si
    <<-S
** ~to_si~
Returns a "string int" representation of a number with underscores for thousands seperator. eg: ~50000.8778~ will be shown as ~50_000~.
S
  end

  def docs_elapsed_time
    <<-S
** ~elapsed_time~
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
      args.state.last_click_at = Kernel.tick_count
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

    # create a state variable that tracks time at half the speed of Kernel.tick_count
    args.state.simulation_tick = Kernel.tick_count.idiv 2

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
