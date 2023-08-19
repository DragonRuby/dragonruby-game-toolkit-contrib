# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# framerate_diagnostics.rb has been released under MIT (*only this file*).

module GTK
  class Runtime
    module FramerateDiagnostics
      def get_framerate_diagnostics
        framerate_get_diagnostics
      end

      def framerate_get_diagnostics
        @framerate_captured_diagnostics ||= {}

        <<-S
* INFO: Framerate Diagnostics
You can display these diagnostics using:

#+begin_src
  def tick args
    # ....

    # IMPORTANT: Put this at the END of the ~tick~ method.
    args.outputs.debug << args.gtk.framerate_diagnostics_primitives
  end
#+end_src

** Draw Calls: ~<<~ Invocation Perf Counter
Here is how many times ~args.outputs.PRIMITIVE_ARRAY <<~ was called:

  #{$perf_counter_outputs_push_count} times invoked.

If the number above is high, consider batching primitives so you can lower the invocation of ~<<~. For example.

Instead of:

#+begin_src
  args.state.enemies.map do |e|
    e.alpha = 128
    args.outputs.sprites << e # <-- ~args.outputs.sprites <<~ is invoked a lot
  end
#+end_src

Do this:

#+begin_src
  args.outputs.sprites << args.state
                              .enemies
                              .map do |e| # <-- ~args.outputs.sprites <<~ is only invoked once.
    e.alpha = 128
    e
  end
#+end_src

** Array Primitives
~Primitives~ represented as an ~Array~ (~Tuple~) are great for prototyping, but are not as performant as using a ~Hash~.

Here is the number of ~Array~ primitives that were encountered:

  #{$perf_counter_primitive_is_array} Array Primitives.

If the number above is high, consider converting them to hashes. For example.

Instead of:

#+begin_src
  args.outputs.sprites << [0, 0, 100, 100, 'sprites/enemy.png']
#+end_src

Do this:

#+begin_src
  args.outputs.sprites << { x: 0,
                            y: 0,
                            w: 100,
                            h: 100,
                            path: 'sprites/enemy.png' }
#+end_src

We will notify of places where that use Array Primitives if you add the following
to your ~tick~ method.

#+begin_src
  def tick args
    # add the following line to the top of your tick method
    $gtk.warn_array_primitives!
  end
#+end_src

** Primitive Counts
Here are the draw counts ordered by lowest to highest z order:

PRIMITIVE          COUNT
solids:            #{@framerate_captured_diagnostics.solids_length}
static_solids:     #{@framerate_captured_diagnostics.static_solids_length}
sprites:           #{@framerate_captured_diagnostics.sprites_length}
static_sprites:    #{@framerate_captured_diagnostics.static_sprites_length}
primitives:        #{@framerate_captured_diagnostics.primitives_length}
static_primitives: #{@framerate_captured_diagnostics.static_primitives_length}
labels:            #{@framerate_captured_diagnostics.labels_length}
static_labels:     #{@framerate_captured_diagnostics.static_labels_length}
lines:             #{@framerate_captured_diagnostics.lines_length}
static_lines:      #{@framerate_captured_diagnostics.static_lines_length}
borders:           #{@framerate_captured_diagnostics.borders_length}
static_borders:    #{@framerate_captured_diagnostics.static_borders_length}
debug:             #{@framerate_captured_diagnostics.debug_length}
static_debug:      #{@framerate_captured_diagnostics.static_debug_length}

** Additional Help
Come to the DragonRuby Discord channel if you need help troubleshooting performance issues. http://discord.dragonruby.org.

Source code for these diagnostics can be found at: [[https://github.com/dragonruby/dragonruby-game-toolkit-contrib/]]
S
      end

      def framerate_warning_message
        <<-S
* WARNING: The average FPS was #{current_framerate}.
- $gtk.get_framerate_diagnostics  : Get framerate diagnostics.
- $gtk.disable_framerate_warning! : Disable this warning.
  S
      end

      def current_framerate_primitives
        framerate_diagnostics_primitives
      end

      def framerate_diagnostics_primitives
        [
          { x: 0, y: 93.from_top, w: 500, h: 93, a: 128 }.solid!,
          {
            x: 5,
            y: 5.from_top,
            text: "More Info via DragonRuby Console: $gtk.framerate_diagnostics",
            r: 255,
            g: 255,
            b: 255,
            size_enum: -2
          }.label!,
          {
            x: 5,
            y: 20.from_top,
            text: "FPS: %.2f" % args.gtk.current_framerate,
            r: 255,
            g: 255,
            b: 255,
            size_enum: -2
          }.label!,
          {
            x: 5,
            y: 35.from_top,
            text: "Draw Calls: #{$perf_counter_outputs_push_count}",
            r: 255,
            g: 255,
            b: 255,
            size_enum: -2
          }.label!,
          {
            x: 5,
            y: 50.from_top,
            text: "Array Primitives: #{$perf_counter_primitive_is_array}",
            r: 255,
            g: 255,
            b: 255,
            size_enum: -2
          }.label!,
          {
            x: 5,
            y: 65.from_top,
            text: "Mouse: #{@args.inputs.mouse.point}",
            r: 255,
            g: 255,
            b: 255,
            size_enum: -2
          }.label!,
        ]
      end

    end
  end
end
