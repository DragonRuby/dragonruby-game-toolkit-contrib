# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# framerate.rb has been released under MIT (*only this file*).

module GTK
  class Runtime
    module Framerate
      def framerate_init
        @tick_time = Time.new.to_i
      end

      def delta_framerate
        (current_framerate || 0) - (@previous_framerate || 0)
      end

      def disable_framerate_warning!
        @framerate_disable_warning = true
        log "Framerate warning disabled. To re-enable, call ~$gtk.enable_framerate_warning!~"
      end

      def enable_framerate_warning!
        @framerate_disable_warning = false
        log "Framerate warning re-enabled. To disable, call ~$gtk.disable_framerate_warning!~"
      end

      def reset_framerate_calculation
        @tick_speed_sum = 0
        @tick_speed_count = 10
        @framerate_warning_message_shown_at = -1
      end

      def framerate_should_show_warning?
        return false if @framerate_disable_warning
        return false if Kernel.global_tick_count < 0
        return false if (Kernel.global_tick_count - (@last_reset_global_at || 0)) < 1800
        return false if (Kernel.global_tick_count - (@last_reload_complete_global_at || 0)) < 1800
        has_debounce_elapsed = if @framerate_warning_message_shown_at == -1
                                 true
                               else
                                 (Kernel.global_tick_count - @framerate_warning_message_shown_at) > 1800
                               end
        !(@console.visible? || @recording.is_replaying?) && has_debounce_elapsed
      end

      def check_framerate
        if @framerate_diagnostics_requested
          log "================================"
          @framerate_diagnostics_requested = false
          log framerate_get_diagnostics if args.inputs.keyboard.has_focus
        end

        if !@paused
          if @tick_time
            @tick_speed_count += 1
            @tick_speed_sum += Time.now.to_i - @tick_time
            if @tick_speed_count > 120
              if framerate_below_threshold?
                @framerate_warning_message_shown_at ||= -1
                if framerate_should_show_warning?
                  GTK::Log.puts_important("* WARNING: Framerate below 30fps for over 120 frames.", message_code: [:framerate_warning])
                  log(framerate_warning_message)
                  @framerate_warning_message_shown_at = Kernel.global_tick_count
                  @framerate_captured_diagnostics = {
                    solids_length: @args.outputs.solids.length,
                    static_solids_length: @args.outputs.static_solids.length,
                    sprites_length: @args.outputs.sprites.length,
                    static_sprites_length: @args.outputs.static_sprites.length,
                    primitives_length: @args.outputs.primitives.length,
                    static_primitives_length: @args.outputs.static_primitives.length,
                    labels_length: @args.outputs.labels.length,
                    static_labels_length: @args.outputs.static_labels.length,
                    lines_length: @args.outputs.lines.length,
                    static_lines_length: @args.outputs.static_lines.length,
                    borders_length: @args.outputs.borders.length,
                    static_borders_length: @args.outputs.static_borders.length,
                    debug_length: @args.outputs.debug.length,
                    static_debug_length: @args.outputs.static_debug.length,
                  }
                end
              end
            end
          end

          @tick_time = Time.new.to_i
        else
          reset_framerate_calculation
        end
      rescue
        reset_framerate_calculation
      end

      def framerate_diagnostics
        # request framerate diagnostics to be printed at the end of tick
        @framerate_diagnostics_requested = true
      end

      def framerate_below_threshold?
        return current_framerate < 30 && Kernel.tick_count > 60
      end

      def current_framerate
        return 60 if !@tick_speed_sum || !@tick_speed_sum
        r = 100.fdiv(@tick_speed_sum.fdiv(@tick_speed_count) * 100)
        if (r.nan? || r.infinite? || r > 58)
          r = 60
        else
          r = r.round
        end
        r || 60
      rescue
        60
      end
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

Source code for these diagnostics can be found in this folder under: =./docs/oss/dragon=.
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
    end # module Framerate
  end # end class Runtime
end # end module GTK
