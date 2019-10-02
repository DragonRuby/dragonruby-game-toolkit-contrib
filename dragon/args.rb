# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# args.rb has been released under MIT (*only this file*).

module GTK
  class Grid
    include Serialize
    SCREEN_Y_DIRECTION = -1.0

    attr_accessor :bottom, :left, :right, :top,
                  :rect, :origin_x, :origin_y, :center_x, :center_y,
                  :name

    def initialize
      origin_bottom_left!
    end

    def __print_origin_help ascii_art
      log_once [:grid_ascii_art, @name], <<-S
The origin has been set to :#{@name}.

#{ascii_art}

You can change the origin using any of
the following methods:

  grid.origin_bottom_left!
  grid.origin_center!

Example:

  def tick args
    args.grid.origin_bottom_left!
  end
S
    end

    def transform_rect x, y, w, h
      new_x = transform_x x
      new_y = transform_y y
      new_w = w.to_f
      new_h = h * SCREEN_Y_DIRECTION

      if new_w < 0
        new_x = new_x + new_w
        new_w = new_w.abs
      end

      if new_h < 0
        new_y = new_y + new_h
        new_h = new_h.abs
      end

      [new_x, new_y, new_w, new_h]
    end

    def transform_x x
      @origin_x + x
    end

    def untransform_x x
      x - @origin_x
    end

    def untransform_y y
      @origin_y + y * SCREEN_Y_DIRECTION
    end

    def transform_y y
      @origin_y + y * SCREEN_Y_DIRECTION
    end

    def transform_angle angle
      (360 - angle).to_i
    end

    def origin_bottom_left!
      return if @name == :bottom_left
      @name = :bottom_left
      @origin_x = 0.0
      @origin_y = 720.0
      @left   = 0.0
      @right  = 1280.0
      @top    = 720.0
      @bottom = 0.0
      @center_x = 640.0
      @center_y = 360.0
      @rect   = [@left, @bottom, 1280.0, 720.0]
      __print_origin_help <<ASCII
(0, 720) +-------------------+ (1280, 720)
         |                   |
         |     (640, 360)    |
         |         +         |
         |                   |
         |                   |
(0, 0)   +-------------------+ (1280, 0)
ASCII
    end

    def origin_center!
      return if @name == :center
      @name = :center
      @origin_x = 640.0
      @origin_y = 360.0
      @left   =  -640.0
      @right  =   640.0
      @top    =   360.0
      @bottom =  -360.0
      @center_x = 0.0
      @center_y = 0.0
      @rect   = [@left, @bottom, 1280.0, 720.0]
      __print_origin_help <<ASCII
(-640,  360) +-------------------+ ( 640, 360)
             |                   |
             |       (0, 0)      |
             |         +         |
             |                   |
             |                   |
(-640, -360) +-------------------+ (-640, 360)
ASCII
    end

    def w
      1280.0
    end

    def w_half
      640.0
    end

    def h
      720.0
    end

    def h_half
      360.0
    end
  end
end

module GTK
  class Args
    include ArgsDeprecated

    attr_accessor :inputs, :outputs, :passes, :runtime,
                  :grid, :recording

    def initialize runtime, recording
      @inputs = Inputs.new
      @outputs = Outputs.new
      @passes = []
      @state = OpenEntity.new
      @state.tick_count = -1
      @runtime = runtime
      @recording = recording
      @grid = Grid.new
      @render_targets = {}
      @all_tests = []
    end

    def gtk
      @runtime
    end

    # @return [OpenEntity] returns `OpenEntity` object that allows for storing state between ticks
    # @example Storing a value in a state
    #   args.state.player_score = 0
    #   args.state.current_time = Time.now
    def state
      @state
    end

    # @param value [OpenEntity] the new state object to use
    # @return [OpenEntity] the new state object
    # @example Overwriting the state object
    #   args.state = OpenEntity.new
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

    # @return [GTK::OutputsArray] the array of solids to render during current tick
    def solids
      @outputs.solids
    end

    def static_solids
      @outputs.static_solids
    end

    # @return [GTK::OutputsArray] the array of sprites to render during current tick
    def sprites
      @outputs.sprites
    end

    def static_sprites
      @outputs.static_sprites
    end

    # @return [GTK::OutputsArray] the array of labels to render during current tick
    def labels
      @outputs.labels
    end

    def static_labels
      @outputs.static_labels
    end

    # @return [GTK::OutputsArray] the array of lines to render during current tick
    def lines
      @outputs.lines
    end

    def static_lines
      @outputs.static_lines
    end

    # @return [GTK::OutputsArray] the array of borders to render during current tick
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

    def controller_one
      @inputs.controller_one
    end

    def controller_two
      @inputs.controller_two
    end
  end
end
