# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# outputs.rb has been released under MIT (*only this file*).

module GTK
  # !!! FIXME: Get rid of this intermediary Sound class and accept a
  #            hash that respects all args.audio properties
  class Sound
    include Serialize
    attr_accessor :path, :gain

    def self.parse v
      return nil unless v

      if v.is_a? String
        return Sound.new({ path: v })
      elsif v.is_a? Hash
        return Sound.new(v)
      elsif v.is_a? Sound
        return v
      else
        raise "* ERROR: I don't know how to parse #{v || "(nil)"} into a #{self}."
      end
    end

    def initialize opts = {}
      if opts[:path]
        @path = opts[:path]
      elsif opts[:input]
        @path = opts[:input]
      end

      @gain = opts[:gain] || 1.0
    end
  end
end

module GTK
  class OutputsArray < Array
    include FlatArrayDeprecated

    def [] *args
      sym_maybe, *rest = args
      super
    end

    def mark_method
      raise "OutputsArray is an abstract class and must be derived. mark_method must be overridden too."
    end

    def mark_and_id! o
      if o.is_a? Array
        $perf_counter_primitive_is_array += 1
      end
      return if resolved? o
      o.send(mark_method)
    end

    def array_primitive? os
      is_primitive = false

      is_primitive = os[-1].is_a? ValueType
      is_primitive = is_primitive || os.any? { |o| o.is_a? ValueType } # the array/tuple is a primitive if it contains any value types
      is_primitive = is_primitive || os.any? do |o|  # the array/tuple is a primitive if it contains an array with 3 values (representing a rgb value)
        ((os.at 1).is_a? Array) &&
          ((os.at 1).length == 3) &&
          ((os.at 1).all? { |os_one| os_one.is_a? Numeric })
      end

      is_primitive = is_primitive || (os.at 0) &&  # the array/tuple is a primitive if it contains a tuple of points [[x, y], [w, h], [r, g, b]]
                     (os.at 0).is_a?(Array) &&
                     (os.at 0).length == 2 &&
                     (os.at 0).at(0).is_a?(Numeric) &&
                     (os.at 0).at(1).is_a?(Numeric)

      is_primitive
    end

    def __push__ other
      $perf_counter_outputs_push_count += 1
      return self if !other
      if other.is_a? Hash
        return add_dwim other
      elsif other.is_a? Array
        return add_dwim other
      elsif !other.is_a? Enumerable
        return add_dwim other
      else
        return add_dwim other.to_a
      end
    end

    alias_method :<<, :__push__
    alias_method :push, :__push__
  end

  module WatchLabels
    def watch o, label_style: nil, background_style: nil
      return if $gtk.production?

      o_to_sf = if o.nil?
                  "nil"
                else
                  o.to_sf
                end

      "#{o_to_sf}".each_line do |l|
        WatchLabels.push self, l, label_style: label_style, background_style: background_style
      end

      if "#{o_to_sf}".end_with? "\n"
        WatchLabels.push self, "", label_style: label_style, background_style: background_style
      end
    end

    def watch_ivars target, label_style: nil, background_style: nil
      return if $gtk.production?
      return if !target

      $gtk_watch_target = target
      $gtk_watch_target.instance_variables.each do |a|
        v = Kernel.eval "return $gtk_watch_target.instance_variable_get(:#{a})"
        watch "#{a}: #{v}", label_style: label_style, background_style: background_style
      end
      $gtk_watch_target = nil
    end

    def watch_attrs target, label_style: nil, background_style: nil
      return if $gtk.production?
      return if !target
      return if !target.class.respond_to? :attributes

      $gtk_watch_target = target
      $gtk_watch_target.class.attributes.each do |a|
        v = Kernel.eval "return $gtk_watch_target.#{a}"
        watch "#{a}: #{v}", label_style: label_style, background_style: background_style
      end
      $gtk_watch_target = nil
    end

    def watch_fps
      return if $gtk.production?
      watch "FPS: #{$gtk.current_framerate}"
    end

    def self.prefab sender:, string:, label_style: nil, background_style: nil
      label_style ||= { size_enum: -3, anchor_y: 0 }
      label_style = { **label_style }

      size_px = label_style[:size_px]
      size_enum = label_style[:size_enum] || -3
      if size_px
        size_enum = (size_px - 22).idiv(2)
      end
      label_style.delete :size_px
      label_style[:size_enum] = size_enum
      label_style[:anchor_y] ||= 0

      background_style ||= {
        path: :solid,
        a: 200,
        r: 255, g: 255, b: 255
      }

      if !background_style[:primitive_marker] && !background_style[:path]
        background_style[:path] = :solid
      end

      w, h = $gtk.calcstringbox string, size_enum
      longest_w = w
      longest_h = h

      @@watch_label_column ||= 0
      @@watch_label_row    ||= 0
      @@watch_label_longest_text ||= []
      @@watch_label_longest_text[@@watch_label_column] ||= {
        string: "",
        w: 0,
        style: label_style,
      }

      if w > @@watch_label_longest_text[@@watch_label_column][:w]
        @@watch_label_longest_text[@@watch_label_column] = {
          string: string,
          w: w,
          style: label_style,
        }
      end

      @@watch_label_running_y ||= 0
      @@watch_primitives  ||=[]
      @@watch_label_count ||= 0
      @@watch_label_count += 1
      @@watch_label_row += 1
      @@watch_label_running_y += h + 4

      if (@@watch_label_running_y + 10) > Grid.h
        @@watch_label_row = 1
        @@watch_label_column += 1
        @@watch_label_running_y = h + 4
      end

      offset_x = Grid.x
      idx = 0
      l = @@watch_label_longest_text.length
      while idx < l
        if idx < @@watch_label_column
          longest_w, longest_h = $gtk.calcstringbox @@watch_label_longest_text[idx][:string], @@watch_label_longest_text[idx][:style][:size_enum]
          offset_x += longest_w + 2
        end
        idx += 1
      end

      @@watch_label_x = offset_x + 16 * @@watch_label_column
      @@watch_label_y = (@@watch_label_running_y).from_top

      x = @@watch_label_x
      y = @@watch_label_y

      border_x = x
      border_y = @@watch_label_y - 2
      border_w = w + 4
      border_h = h + 4

      {
        label: {
          **label_style,
          x: x + 1,
          y: y,
          text: "#{string}",
          __watch_label_source__: "#{sender.class.name}" },
        background: {
          **background_style,
          x: border_x,
          y: border_y,
          w: border_w,
          h: border_h,
        }
      }
    end

    def self.push source, string, label_style: nil, background_style: nil
      prefab = WatchLabels.prefab sender: self, string: string, label_style: label_style, background_style: background_style
      @@watch_primitives << prefab[:background]
      @@watch_primitives << prefab[:label]
      source << prefab[:background]
      source << prefab[:label]
    end

    def __push__ other
      if other.is_a? String
        watch other
      else
        super(other)
      end
    end

    alias_method :<<, :__push__
    alias_method :push, :__push__

    def self.watch_primitives
      @@watch_primitives ||= []
    end

    def self.clear
      @@watch_label_count = 0
      @@watch_label_column = 0
      @@watch_label_row = 0
      @@watch_label_running_y = 0
      @@watch_label_longest_text = []
      watch_primitives.clear
    end

    def self.watch_label_count
      @@watch_label_count
    end
  end

  class GenericOutputsArray < OutputsArray
    def resolved? o
      if o && !o.is_a?(Array) && !o.primitive_marker
        raise <<-S
* ERROR:
#{o}

I don't know how to use the above #{o.class} with SDL's FFI. Please
add a method on the object called ~primitive_marker~ that
returns :solid, :sprite, :label, :line, or :border. If the object
is a Hash, please add { primitive_marker: :PRIMITIVE_SYMBOL } to the Hash.

S
      end

      super
    end

    def mark_method
      :mark_assert!
    end
  end

  class SolidsOutputsArray < OutputsArray
    def mark_method
      :mark_as_solid!
    end
  end

  class StaticSolidsOutputsArray < OutputsArray
    def mark_method
      :mark_as_solid!
    end
  end

  class SpritesOutputsArray < OutputsArray
    def mark_method
      :mark_as_sprite!
    end
  end

  class StaticSpritesOutputsArray < OutputsArray
    def mark_method
      :mark_as_sprite!
    end
  end

  class LabelsOutputsArray < OutputsArray
    def mark_method
      :mark_as_label!
    end
  end

  class StaticLabelsOutputsArray < OutputsArray
    def mark_method
      :mark_as_label!
    end
  end

  class BordersOutputsArray < OutputsArray
    def mark_method
      :mark_as_border!
    end
  end

  class StaticBordersOutputsArray < OutputsArray
    def mark_method
      :mark_as_border!
    end
  end

  class LinesOutputsArray < OutputsArray
    def mark_method
      :mark_as_line!
    end
  end

  class StaticLinesOutputsArray < OutputsArray
    def mark_method
      :mark_as_line!
    end
  end

  class ReservedOutputsArray < GenericOutputsArray
    include WatchLabels
  end

  class StaticReservedOutputsArray < GenericOutputsArray
  end

  class DebugOutputsArray < GenericOutputsArray
    include WatchLabels
  end

  class StaticDebugOutputsArray < GenericOutputsArray
  end

  class PrimitivesOutputsArray < GenericOutputsArray
  end

  class StaticPrimitivesOutputsArray < GenericOutputsArray
  end
end # end GTK module

module GTK
  class PixelArray
    attr_accessor :width, :height, :pixels

    def initialize
      @width = 0
      @height = 0
      @pixels = []
    end

    def w
      @width
    end

    def w= value
      @width = value
    end

    def h
      @height
    end

    def h= value
      @height = value
    end
  end
end

module GTK
  class Outputs   # Each Outputs is a single render pass to a render target (or the window framebuffer).
    include OutputsDeprecated

    attr_accessor :target, :width, :height, :transient, :background_color, :clear_before_render

    attr_reader :solids, :sprites, :lines, :labels, :borders, :primitives, :reserved, :debug,
                :static_solids, :static_sprites, :static_lines, :static_labels, :static_borders, :static_primitives, :static_reserved,
                :static_debug,
                :screenshots, :a11y, :a11y_processed, :a11y_notification_queue

    def initialize opts = {}
      @target = nil
      @target = opts[:target].to_s if opts[:target]
      @width   = opts[:width] || $gtk.logical_width
      @height  = opts[:height] || $gtk.logical_height
      @args = opts[:args]

      if !@args.is_a? Args
        raise "Outputs.new must pass in an :args named-parameter that is non-nil and is_a? Args."
      end

      __initialize_primitives

      @reserved = ReservedOutputsArray.new
      @debug    = DebugOutputsArray.new

      @static_reserved   = StaticReservedOutputsArray.new
      @static_debug      = StaticDebugOutputsArray.new

      @background_color = opts[:background_color_override] || default_background_color
      @clear_before_render = true

      @sounds  = []
      @a11y = {}
      @a11y_processed = {}
      @a11y_notification_queue = []
      @screenshots = SpritesOutputsArray.new
    end

    def __initialize_primitives
      @solids            = SolidsOutputsArray.new
      @sprites           = SpritesOutputsArray.new
      @labels            = LabelsOutputsArray.new
      @lines             = LinesOutputsArray.new
      @borders           = BordersOutputsArray.new
      @primitives        = PrimitivesOutputsArray.new
      @static_solids     = StaticSolidsOutputsArray.new
      @static_sprites    = StaticSpritesOutputsArray.new
      @static_labels     = StaticLabelsOutputsArray.new
      @static_lines      = StaticLinesOutputsArray.new
      @static_borders    = StaticBordersOutputsArray.new
      @static_primitives = StaticPrimitivesOutputsArray.new
    end

    def default_background_color
      [230, 230, 230, 255]
    end

    def watch(...)
      @debug.watch(...)
    end

    def watch_ivars(...)
      @debug.watch_ivars(...)
    end

    def watch_attrs(...)
      @debug.watch_attrs(...)
    end

    def watch_fps(...)
      @debug.watch_fps(...)
    end

    def background_color= value
      return if value == @background_color || value == @background_color_as_hash

      value_as_array = value

      if value.is_a? Hash
        value_as_array = [value.r, value.g, value.b, value.a]
      end

      value_as_array.compact!

      @background_color = value_as_array
      @background_color_as_hash = { r: value_as_array[0], g: value_as_array[1], b: value_as_array[2], a: value_as_array[3] }
    rescue Exception => e
      target_name = "args.outputs.background_color"
      if @target
        target_name = "args.outputs[:#{@target}].background_color"
      end
      raise e,  <<-S
* ERROR: Failed to set background_color for Output.
The ~value~ sent to

  #{target_name}=

looks invalid

  #{value} (#{value.class})

~Outputs#background_color must be an ~Array~ with three or four values representing the background color's rgba. For example:

#+begin_src
  #{target_name} = [255, 0, 0] # red background
#+end_src

#{e}

S
    end

    def background_color
      return [0, 0, 0] if $gtk.load_status != :ready
      return [0, 0, 0] if Kernel.global_tick_count < 0
      r, g, b, a = @background_color
      r ||= 230
      g ||= 230
      b ||= 230
      a ||= 255
      [r, g, b, a]
    end

    def clear_before_render= value
      @clear_before_render = value
    end

    def clear_before_render
      @clear_before_render
    end

    def tick
      @target ||= nil
      @width  ||= $gtk.logical_width
      @height ||= $gtk.logical_height
      @sounds ||= []
      @sounds   = @sounds.map { |s| Sound.parse(s) }
      @a11y   ||= {}
    end

    def a11y_scrub
      scrubbed_a11y = {}
      @a11y.compact!
      @a11y.each do |k, v|
        scrubbed_a11y[k.to_s] = v
      end

      scrubbed_a11y.each do |k, v|
        v.a11y_id = k
        v.a11y_trait = v.a11y_trait.to_s
        v.a11y_notification_target = v.a11y_notification_target.to_s
        v.a11y_text = v.a11y_text.to_s
        v.a11y_notification_debounce ||= 0
        v.a11y_created_global_at ||= Kernel.global_tick_count
        v.a11y_hidden ||= false
        if v.key?(:w) && v[:w].nil?
          v.delete :w
        end

        if v.key?(:h) && v[:h].nil?
          v.delete :h
        end
      end

      scrubbed_a11y.reject! do |k, v|
        v.notification_trait == "notification" && v.a11y_text.length == 0 && v.a11y_notification_target.length == 0
      end

      scrubbed_a11y.reject! do |k, v|
        v.notification_trait == "notification" && v.a11y_notification_target.length > 0 && !scrubbed_a11y[v.a11y_notification_target]
      end

      scrubbed_a11y
    end

    def get_a11y_entry_error all_entries, k, v
      if !k.is_a?(String) || k.length == 0
        return <<-S
* ERROR: A11y invalid for #{k}. The key must be of type Symbol or String and have a length greater than zero.
#{v}
S
      end

      if v.a11y_trait != "label" && v.a11y_trait != "notification" && v.a11y_trait != "button"
        return <<-S
* ERROR: A11y invalid for #{k}. ~:a11y_trait~ must be either ~:label~, :notification, or ~:button~.
#{v}
S
      end

#       if v.a11y_trait != "notification" && v.a11y_text.length == 0
#         return <<-S
# * ERROR: A11y invalid for #{k}. ~:a11y_text~ must be of type String and have a length greater than zero.
# #{v}
# S
#       end


      if v.a11y_trait == "notification"
        if v.a11y_notification_target.length == 0 && v.a11y_text.length == 0
          return <<-S
* ERROR: A11y invalid for #{k}. ~:a11y_notification_target~ must be set or ~:a11y_text~ must be set.
#{v}
S
        end

        if v.a11y_notification_target.length > 0 && v.a11y_text.length > 0
          return <<-S
* ERROR: A11y invalid for #{k}. ~:a11y_notification_target~ and ~:a11y_text~ cannot both be set.
#{v}
S
        end

        if v.a11y_trait == "button" && (!v.w || !v.h)
          return <<-S
* ERROR: A11y invalid for #{k}. ~:w~ and ~:h~ must be set for a ~:a11y_trait~ with value of ~:button~.
#{v}
S
        end

#         if v.a11y_notification_target.length > 0 && !all_entries[v.a11y_notification_target]
#           return <<-S
# * ERROR: A11y invalid for #{k}. ~:a11y_notification_target~ must be a valid key in the a11y hash or nil.
# a11y_notification_target: #{v.a11y_notification_target}
# available targets: #{all_entries.keys.join(", ")}
# S
#         end
      end
    end

    def tick_a11y
      if !GTK.a11y_enabled?
        @a11y.clear
        return
      end

      @a11y_processed = {}

      scrubbed = a11y_scrub
      scrubbed.each do |k, v|
        next if v.a11y_hidden
        tmp = { **v }
        rect = tmp.slice(:x, :y, :w, :h, :anchor_x, :anchor_y)

        if tmp.a11y_trait == "label"
          rect.anchor_y ||= 1
          rect.anchor_x ||= 0
        end

        if tmp.a11y_trait == "notification"
          rect = { x: 0, y: 0, w: 0, h: 0 }
        else
          if tmp.a11y_trait == "label" && (!tmp.w || !tmp.h)
            newlines = tmp.a11y_text.split("\n")
            longest_line = newlines.max_by(&:length)
            w, h = GTK.calcstringbox(longest_line, size_enum: tmp.size_enum, size_px: tmp.size_px, font: tmp.font)
            rect.w = w
            rect.h = h
          else
            rect = tmp.slice(:x, :y, :w, :h, :anchor_x, :anchor_y)
          end

          rect = Geometry.rect_props(rect)
        end


        @a11y_processed[k.to_s] = rect.merge(tmp.slice(:a11y_id,
                                                       :a11y_text,
                                                       :a11y_trait,
                                                       :a11y_notification_target,
                                                       :a11y_notification_debounce,
                                                       :a11y_created_global_at))
      end

      # with a11y_processed populated, get all a11y_trait of type notification
      notification_targets = @a11y_processed.find_all { |k, v| v[:a11y_trait] == "notification" }

      # if a control focus notification is present, clear all notifications
      if notification_targets.any? { |k, v| v[:a11y_notification_target].length > 0 }
        @a11y_notification_queue.reject! do |h|
          h[:a11y_entry][:a11y_trait] == "notification" &&
          h[:a11y_entry][:a11y_text].length > 0 &&
          (h[:a11y_entry][:a11y_created_global_at] + (h[:a11y_entry][:a11y_notification_debounce] || 0)) <= Kernel.global_tick_count
        end
        @a11y_dequeue_notification_global_at = Kernel.global_tick_count
      end

      # queue up all notification traits
      notification_targets.each do |k, v|
        @a11y_notification_queue << { a11y_id: k, a11y_entry: v }
      end

      # remove all notification traits from @a11y_processed
      @a11y_processed.reject! { |k, v| v[:a11y_trait] == "notification" }

      @a11y_dequeue_notification_global_at ||= 0

      if $args.inputs.a11y.activated
        @a11y_dequeue_notification_global_at = Kernel.global_tick_count + 60
      end

      # sort the queue by the time it should be dequeued and get the first item
      if Kernel.global_tick_count >= @a11y_dequeue_notification_global_at
        notification_to_run = @a11y_notification_queue.find_all  { |v| v[:a11y_entry][:a11y_created_global_at] + v[:a11y_entry][:a11y_notification_debounce] <= Kernel.global_tick_count }
                                                      .sort_by { |v| v[:a11y_entry][:a11y_created_global_at] + v[:a11y_entry][:a11y_notification_debounce] }.first

        if notification_to_run
          @a11y_notification_queue.delete notification_to_run

          should_process_notification = true

          if notification_to_run[:a11y_entry][:a11y_notification_target].length > 0
            target_exists = @a11y_processed[notification_to_run[:a11y_entry][:a11y_notification_target]]

            if !target_exists
              $gtk.notify "A11y Notification Warning: A11y Notification Target does not exist: #{notification_to_run[:a11y_entry][:a11y_notification_target]}. Skipping."
              should_process_notification = false
            end
          end

          if should_process_notification
          @a11y_processed[notification_to_run[:a11y_id]] = notification_to_run[:a11y_entry]

          if notification_to_run[:a11y_entry][:a11y_notification_target].length > 0
            @a11y_dequeue_notification_global_at = Kernel.global_tick_count + 60 * 2
          elsif notification_to_run[:a11y_entry][:a11y_text].length > 0
            words = notification_to_run[:a11y_entry][:a11y_text].split(" ").length
            @a11y_dequeue_notification_global_at = Kernel.global_tick_count + (60 * words / 2).to_i
          end
          end
        end
      end

      errorneous = []
      @a11y_processed.each do |k, v|
        result = get_a11y_entry_error @a11y_processed, k, v
        if result
          errorneous << { error: result, key: k, value: v }
        end
      end

      @a11y_processed.reject! do |k, v|
        errorneous.any? { |e| e[:key] == k }
      end

      if errorneous.length > 0
        error_message = errorneous.map { |e| e[:error] }.join("\n")
        raise error_message if !$gtk.production?
      end

      @a11y.clear
    end

    def a11y_pending_notifications?
      return true if @a11y_processed.any? { |k, n| n.a11y_trait == "notification" }
      return true if @a11y_notification_queue.length > 0
      return false
    end

    def a11y_clear_pending_notifications!
      @a11y_notification_queue.clear
      @a11y_dequeue_notification_global_at = Kernel.global_tick_count
    end

    def can_screenshot?
      Kernel.tick_count > 0
    end

    def clear_non_static
      @background_color = default_background_color
      @clear_before_render = true
      @screenshots.clear if can_screenshot?

      @labels.clear
      @sprites.clear
      @lines.clear
      @solids.clear
      @borders.clear
      @primitives.clear
      @debug.clear
      @a11y.clear
      WatchLabels.clear
    end

    def clear_non_static_reserved
      @reserved.clear
      WatchLabels.clear
    end

    def reset
      clear
      @a11y.clear
      @a11y_processed.clear
      @a11y_notification_queue.clear
      @a11y_dequeue_notification_global_at = Kernel.global_tick_count
    end

    def clear
      clear_non_static
      @static_labels.clear
      @static_sprites.clear
      @static_lines.clear
      @static_solids.clear
      @static_borders.clear
      @static_primitives.clear
      @static_reserved.clear
      @static_debug.clear
      WatchLabels.clear
    end

    def inspect
      serialize.to_s
    end

    def serialize
      {
        solids:            @solids.map { |s| s.serialize },
        sprites:           @sprites.map { |s| s.serialize },
        lines:             @lines.map { |s| s.serialize },
        labels:            @labels.map { |s| s.serialize },
        sounds:            @sounds.map { |s| s.serialize },
        borders:           @borders.map { |s| s.serialize },
        primitives:        @primitives.map { |s| s.serialize },
        static_solids:     @static_solids.map { |s| s.serialize },
        static_borders:    @static_borders.map { |s| s.serialize },
        static_sprites:    @static_sprites.map { |s| s.serialize },
        static_lines:      @static_lines.map { |s| s.serialize },
        static_labels:     @static_labels.map { |s| s.serialize },
        static_primitives: @static_primitives.map { |s| s.serialize },
      }
    end

    def render_target name
      @args.render_target value
    end

    def [] value
      @args.render_target value
    end

    def sounds
      @sounds
    end

    def sounds= value
      @sounds = value
    end

    def transient!
      @transient = true
      self
    end

    def << other
      @primitives << other
    end

    def width
      @width
    end

    def __warn_outputs_size__ size, dimension
      return if !size
      if size > 1600
        log_once_key = ("render_target_#{@target}" || "top_level").to_sym
        log_once_important log_once_key, <<-S
* WARNING: Render target size is above what Android can render.

The render target named ~#{@target}~ has a #{dimension} of #{size} pixels. This size is larger 1600
pixels and WILL NOT render on Android devices.
S
      end
    end

    def width= value
      @width = value
    end

    def height
      @height
    end

    def height= value
      @height = value
    end

    alias_method :w, :width
    alias_method :w=, :width=
    alias_method :h, :height
    alias_method :h=, :height=
  end

  class TopLevelOutputs < Outputs
    # bug repro if the background_color override didn't exist
    # #+begin_src
    #   def tick args
    #     args.state.bg_toggle_state ||= 0
    #     if args.inputs.keyboard.key_down.space
    #       args.state.bg_toggle_state += 1
    #     end
    #     args.state.bg_toggle_state = 0 if args.state.bg_toggle_state > 3
    #     args.outputs.debug << "bg_toggle_state: #{args.state.bg_toggle_state}"
    #     case args.state.bg_toggle_state
    #     when 0
    #       args.outputs.background_color = [255, 0, 0]
    #     when 1
    #       args.outputs.background_color = [255, 0, 0, 0]
    #     when 2
    #       args.outputs.background_color = { r: 255, g: 0, b: 0 }
    #     when 3
    #       args.outputs.background_color = { r: 255, g: 0, b: 0, a: 255 }
    #     end
    #   end
    # #+end_src
    def background_color= value
      super
      @background_color_as_hash[:a] = nil
      @background_color_as_hash
    end
  end

  class RenderTargetOutputs < Outputs
    def initialize(...)
      super(...)
      @transient = true
    end
  end
end

GTKTopLevelOutputs = GTK::TopLevelOutputs
