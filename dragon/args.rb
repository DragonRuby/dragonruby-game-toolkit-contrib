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
      @outputs = TopLevelOutputs.new args: self
      @cvars = {}
      $cvars     ||= @cvars
      @audio = AudioHash.new
      @passes = []
      if runtime.__state_assigned_to_hash_on_boot__
        @state = {}
        @temp_state = {}
      else
        @state = OpenEntity.new
        @temp_state = OpenEntity.new
      end
      @state.tick_count = -1
      @runtime = runtime
      @recording = recording
      @grid = Grid.new runtime
      @render_targets = {}
      @render_target_sizes = {}
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
      $layout = @layout
      @easing = GTK::Easing
      @string = String
      @events = {
        resize_occurred: false,
        raw: []
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
        state:      state ? state.as_hash : state,
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

    def capture_render_target_sizes
      @render_targets.each do |name, rt|
        @render_target_sizes[name] = { w: rt.w, h: rt.h }
      end
    end

    def render_targets
      @render_targets
    end

    def render_target name
      name = name.to_s

      if name == "pixel" || name == "solid"
        raise <<~S
              * ERROR: Unable to create render target with name ~#{name}~.
              The render target name ~#{name}~ is reserved/used by DragonRuby.
              Please use another name for your render target.
              S
      end

      if !@render_targets[name]
        render_target_data = {
          id: name,
          initial_position: @outputs.render_targets.__data__.size,
          path: name,
          ready: false,
          ready_at: Kernel.tick_count + 1,
          global_created_at: Kernel.global_tick_count + 1,
          updated_at: Kernel.tick_count ,
          global_updated_at: Kernel.global_tick_count,
          w: @render_target_sizes[name]&.w || @grid.w,
          h: @render_target_sizes[name]&.h || @grid.h,
        }
        @outputs.render_targets.__data__[name] = render_target_data
        @render_targets[name] = RenderTargetOutputs.new(args: self,
                                                        target: name,
                                                        background_color_override: [255, 255, 255, 0],
                                                        render_target_data: render_target_data)
        if @render_target_sizes[name]
          @render_targets[name].w = @render_target_sizes[name].w
          @render_targets[name].h = @render_target_sizes[name].h
        end
        @passes << @render_targets[name]
      end

      @outputs.render_targets.__data__[name].updated_at = Kernel.tick_count
      @outputs.render_targets.__data__[name].global_updated_at = Kernel.global_tick_count

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

    def tick_before
      @current_audio_object_ids = @audio.values.map { |v| v.object_id }
    end

    def __clear_events__
      return if Kernel.global_tick_count < 0
      @events[:orientation_changed] = false
      $grid.orientation_changed = false
      @events[:resize_occurred] = false
      @events[:raw].clear
    end

    def tick_after
      @inputs.touch.each { |k, v| v.first_tick_down = false }
      @temp_state.clear!
      __clear_events__

      new_audio_data = {}

      new_audio_object_ids = @audio.find_all do |k, v|
        !@current_audio_object_ids.include?(v.object_id)
      end.map { |k, v| v.object_id }

      new_audio_object_ids.each do |id|
        _, audio_v = @audio.find { |k, v| v.object_id == id }
        if audio_v
          new_audio_data[id] = {
            gain: audio_v[:gain] || 1.0,
            playtime: audio_v[:playtime] || 0.0,
            original_source: audio_v
          }
          audio_v[:gain] = 0
        end
      end

      if new_audio_data.length > 0
        new_audio_data.each do |k, v|
          @runtime.update_simulation_audio_state
        end

        new_audio_data.each do |k, v|
          v[:original_source][:playtime] = v[:playtime]
          v[:original_source][:gain] = v[:gain]
          @runtime.update_simulation_audio_state
        end
      end

      @outputs.render_targets.__data__.each do |k, v|
        v[:ready] = true
      end
    end

    def reset
      if @state
        @state.tick_count = Kernel.tick_count
      end
      @outputs.reset
      @audio.clear
      __clear_events__
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
    @volume ||= if $gtk.platform?(:ios)
                  0.4
                else
                  1.0
                end
    # do not mute if tick_count is 0
    return @volume if Kernel.tick_count == 0

    # do not mute if in dev mode
    return @volume if !$args.gtk.production

    # do not mute if platform is anything other than web
    return @volume if !$args.gtk.platform? :web

    # do not mute if game has focus
    return @volume if $args.inputs.keyboard.has_focus

    # mute volume if the platform is web in a production environment,
    # and the game doesn't have focus
    return 0.0
  end

  def volume= value
    @volume = value
    @volume = @volume.clamp(0.0, 1.0)
  end

  def sync!
    GTK.update_simulation_audio_state
  end
end

