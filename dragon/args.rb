# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# args.rb has been released under MIT (*only this file*).

module GTK
  class Args
    include ArgsDeprecated

    attr_accessor :inputs, :outputs, :passes, :runtime,
                  :grid, :recording, :geometry

    def initialize runtime, recording
      @inputs = Inputs.new
      @outputs = Outputs.new
      @passes = []
      @state = OpenEntity.new
      @state.tick_count = -1
      @runtime = runtime
      @recording = recording
      @grid = Grid.new runtime.ffi_draw
      @render_targets = {}
      @all_tests = []
      @geometry = GTK::Geometry
    end

    def tick_count
      @state.tick_count
    end

    def tick_count= value
      @state.tick_count = value
    end

    def gtk
      @runtime
    end

    def state
      @state
    end

    def state= value
      @state = value
    end

    def serialize
      {
        state: state.hash,
        inputs: inputs.serialize,
        passes: passes.serialize,
        outputs: outputs.serialize,
        grid: grid.serialize
      }
    end

    def destructure
      [grid, inputs, state, outputs, runtime, passes]
    end

    def clear_render_targets
      @render_targets = {}
    end

    def render_target name
      name = name.to_s
      if !@render_targets[name]
        @render_targets[name] = Outputs.new name
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

      @inpust.mouse.click.created_a
    end

    def mouse
      @inputs.mouse
    end

    def controller_one
      @inputs.controller_one
    end

    def controller_two
      @inputs.controller_two
    end
  end
end
