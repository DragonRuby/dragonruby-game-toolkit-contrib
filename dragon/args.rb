# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# args.rb has been released under MIT (*only this file*).

module GTK
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
    attr_accessor :events
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
      @audio = AudioHash.new
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
      @render_targets_render_at = {}
      @wizards = Wizards.new
      ratio_w = 16
      ratio_h = 9
      if runtime.orientation == :portrait
        ratio_w = 9
        ratio_h = 16
      end
      @layout = GTK::Layout.new @grid.w, @grid.h, ratio_w, ratio_h, runtime.orientation
      @easing = GTK::Easing
      @string = String
      @events = {
        resize_occurred: false
      }
    end

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
        @render_targets[name].transient! if @runtime.platform? :web
        @passes << @render_targets[name]
      end
      @render_targets[name]
    end

    def render_targets_render_at
      @render_targets_render_at ||= {}
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

    def controller_one
      @inputs.controller_one
    end

    def controller_two
      @inputs.controller_two
    end

    def controller_three
      @inputs.controller_three
    end

    def controller_four
      @inputs.controller_four
    end

    def autocomplete_methods
      [:inputs, :outputs, :gtk, :state, :geometry, :audio, :grid, :layout, :fn]
    end

    def reset
      @state.tick_count = Kernel.tick_count
      @outputs.clear
      @audio.clear
      # on reset of the game, we want to clear out render target's historical events
      # this hash is used to control whether a render target will be marked as transient or not
      @render_targets_render_at.clear
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

class AudioHash < Hash
  def volume
    @volume ||= 1.0
    if $args.gtk.production &&
       $args.state.tick_count != 0 &&
       $args.inputs.keyboard.has_focus
      @volume
    elsif !$args.gtk.production
      @volume
    else
      0.0
    end
  end

  def volume= value
    @volume = value
    @volume = @volume.clamp(0.0, 1.0)
  end
end
