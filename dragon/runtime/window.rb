# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# window.rb has been released under MIT (*only this file*).

module GTK
  class Runtime
    module Window
      def can_resize_window?
        return false if platform? :steamdeck
        return false if platform? :ios
        return false if platform? :android
        return true
      end

      def can_move_window?
        return false if platform? :steamdeck
        return false if platform? :ios
        return false if platform? :android
        return false if platform? :web
        return true
      end

      def can_close_window?
        return false if platform? :ios
        return false if platform? :web
        return true
      end

      def toggle_window_fullscreen
        set_window_fullscreen !window_fullscreen?
      end

      def set_window_fullscreen enable=true
        return if @window_fullscreen == enable
        @window_fullscreen = enable
        self.ffi_draw.toggle_fullscreen enable

        # when going into fullscreen, reset the mouse grab (macos constrains the mouse to the previous window size)
        self.ffi_draw.set_mouse_grab 0
        self.ffi_draw.set_mouse_grab @mouse_grab.to_i
      end

      def set_window_title title
        self.ffi_draw.set_window_title (title || "")
      end

      def set_window_scale scale, aspect_unit_w = 16, aspect_unit_h = 9
        @ffi_draw.set_window_scale scale, aspect_unit_w, aspect_unit_h
      end

      def window_fullscreen?
        @window_fullscreen
      end

      def move_window_to_next_display
        return if !can_move_window?
        @ffi_draw.move_window_to_next_display
      end

      def maximize_window
        return if !can_resize_window?
        @ffi_draw.maximize_window
      end

      def can_change_orientation?
        return false if platform? :steamdeck
        return Cvars["game_metadata.orientation_both"].value if platform? :ios
        return Cvars["game_metadata.orientation_both"].value if platform? :android
        return false if platform? :web
        return true
      end

      def set_orientation orientation_name
        return if @orientation == orientation_name
        toggle_orientation
      end

      def toggle_orientation
        return if !can_change_orientation?
        @ffi_draw.toggle_orientation
      end

      def set_hd_max_scale value
        if !Grid.hd?
          puts <<-S
* INFO - ~set_hd_max_scale~ ignored.
HD Mode is not enabled. Go to your game's =metadata/game_metadata.txt= file, make the following changes, and restart:

  # enable HD Mode
  hd=true

  # optionally enable High DPI
  highdpi=true

  # optionally disable letterbox
  hd_letterbox=false

S
          return
        end

        @ffi_draw.set_hd_max_scale value
      end

      def set_scale_quality value
        @ffi_draw.set_scale_quality value
      end

      def set_hd_letterbox value
        return if Grid.letterbox == value
        toggle_hd_letterbox
      end

      def toggle_hd_letterbox
        if !Grid.hd?
          puts <<-S
* INFO - ~set_hd_max_scale~ ignored.
HD Mode is not enabled. Go to your game's =metadata/game_metadata.txt= file, make the following changes, and restart:

  # enable HD Mode
  hd=true

  # optionally enable High DPI
  highdpi=true

  # optionally disable letterbox
  hd_letterbox=false

S
          return
        end

        Grid.letterbox = !Grid.letterbox?
        @ffi_draw.toggle_hd_letterbox
      end
    end
  end
end

module GTK
  class Runtime
    include Window
  end
end
