# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# args.rb has been released under MIT (*only this file*).

module GTK
  # This class is the one you'll interact with the most. It's
  # constructed by the DragonRuby Runtime and is provided to you on
  # each tick.
  class Args
    include ArgsDeprecated
    include Serialize
    attr_accessor :cvars
    attr_accessor :inputs
    attr_accessor :outputs
    attr_accessor :audio
    attr_accessor :grid
    attr_accessor :recording
    attr_accessor :geometry
    attr_accessor :fn
    attr_accessor :state
    attr_accessor :temp_state
    attr_accessor :runtime
    alias_method :gtk, :runtime
    attr_accessor :passes
    attr_accessor :wizards
    attr_accessor :layout
    attr_accessor :easing
    attr_accessor :string

    def initialize runtime, recording
      @inputs = Inputs.new
      @outputs = Outputs.new args: self
      @cvars = {}
      @audio = {}
      @passes = []
      @state = OpenEntity.new
      @temp_state = OpenEntity.new
      @state.tick_count = -1
      @runtime = runtime
      @recording = recording
      @grid = Grid.new runtime
      @render_targets = {}
      @pixel_arrays = {}
      @all_tests = []
      @geometry = GTK::Geometry
      @fn = GTK::Fn
      @wizards = Wizards.new
      @layout = GTK::Layout.new @grid.w, @grid.h
      @easing = GTK::Easing
      @string = String
    end


    # The number of ticks since the start of the game.
    #
    # @return [Integer]
    def tick_count
      @state.tick_count
    end

    def tick_count= value
      @state.tick_count = value
    end

    def serialize
      {
        state:      state.as_hash,
        temp_state: temp_state.as_hash,
        inputs:     inputs.serialize,
        passes:     passes.serialize,
        outputs:    outputs.serialize,
        grid:       grid.serialize
      }
    end

    def destructure
      [grid, inputs, state, outputs, runtime, passes]
    end

    def clear_pixel_arrays
      pixel_arrays_clear
    end

    def pixel_arrays_clear
      @pixel_arrays = {}
    end

    def pixel_arrays
      @pixel_arrays
    end

    def pixel_array name
      name = name.to_s
      if !@pixel_arrays[name]
        @pixel_arrays[name] = PixelArray.new
      end
      @pixel_arrays[name]
    end

    def clear_render_targets
      render_targets_clear
    end

    def render_targets_clear
      @render_targets = {}
    end

    def render_targets
      @render_targets
    end

    def render_target name
      name = name.to_s
      if !@render_targets[name]
        @render_targets[name] = Outputs.new(args: self, target: name, background_color_override: [255, 255, 255, 0])
        @passes << @render_targets[name]
      end
      @render_targets[name]
    end

    def solids
      @outputs.solids
    end

    def static_solids
      @outputs.static_solids
    end

    def sprites
      @outputs.sprites
    end

    def static_sprites
      @outputs.static_sprites
    end

    def labels
      @outputs.labels
    end

    def static_labels
      @outputs.static_labels
    end

    def lines
      @outputs.lines
    end

    def static_lines
      @outputs.static_lines
    end

    def borders
      @outputs.borders
    end

    def static_borders
      @outputs.static_borders
    end

    def primitives
      @outputs.primitives
    end

    def static_primitives
      @outputs.static_primitives
    end

    def keyboard
      @inputs.keyboard
    end

    def click
      return nil unless @inputs.mouse.click

      @inputs.mouse.click.point
    end

    def click_at
      return nil unless @inputs.mouse.click

      @inputs.mouse.click.created_at
    end

    def mouse
      @inputs.mouse
    end

    # @see Inputs#controller_one
    # @return (see Inputs#controller_one)
    def controller_one
      @inputs.controller_one
    end

    # @see Inputs#controller_two
    # @return (see Inputs#controller_two)
    def controller_two
      @inputs.controller_two
    end

    def autocomplete_methods
      [:inputs, :outputs, :gtk, :state, :geometry, :audio, :grid, :layout, :fn]
    end

    def method_missing name, *args, &block
      if (args.length <= 1) && (@state.as_hash.key? name)
        raise <<-S
* ERROR - :#{name} method missing on ~#{self.class.name}~.
The method
  :#{name}
with args
  #{args}
doesn't exist on #{inspect}.
** POSSIBLE SOLUTION - ~args.state.#{name}~ exists.
Did you forget ~.state~ before ~.#{name}~?
S
      end

      super
    end
  end
end
