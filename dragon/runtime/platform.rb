# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# platform.rb has been released under MIT (*only this file*).

module GTK
  class Runtime
    module Platform
      def platform_mappings
        if !@platform_mappings
          baseline = {
            "Mac OS X"   => [:desktop, :macos, :osx, :mac, :macosx],
            "Windows"    => [:desktop, :windows, :win],
            "Linux"      => [:desktop, :linux, :nix],
            "Emscripten" => [:web, :wasm, :html, :emscripten],
            "iOS"        => [:mobile, :ios, :touch],
            "Android"    => [:mobile, :android, :touch],
            "Steam Deck" => [:steamdeck, :steam_deck, :steam],
          }

          if @args.inputs.touch_enabled && @platform == "Emscripten"
            baseline["Emscripten"] << :touch
          end

          if @is_steam_release
            baseline["Mac OS X"] << :steam
            baseline["Mac OS X"] << :steam_desktop
            baseline["Mac OS X"] << :steamdesktop
            baseline["Windows"] << :steam
            baseline["Windows"] << :steam_desktop
            baseline["Windows"] << :steamdesktop
            baseline["Linux"] << :steam
            baseline["Linux"] << :steam_desktop
            baseline["Linux"] << :steamdesktop
          end

          @platform_mappings = baseline
        end

        @platform_mappings
      end

      def platform
        @platform
      end

      def platform= value
        if !platform_mappings.keys.include? value
          valid_platform_values = platform_mappings.keys.map do |k|
            "  $gtk.platform = \"#{k}\""
          end
          raise <<-S
* ERROR: Invalid platform was provided.
These are valid platform values:
#+begin_src
  # view platform mappings
  puts $gtk.platform_mappings
#{valid_platform_values.join "\n"}
#+end_src

Additionally you can set the ~is_steam_release~ property to emulate Steam Desktop:

#+begin_src
  $gtk.is_steam_release = true
  puts $gtk.platform?(:steamdesktop) # true
#+end_src
S
        end
        @platform = value
        @platform_mappings = nil
      end

      def is_steam_release
        @is_steam_release
      end

      def is_steam_release=(value)
        @is_steam_release = value
        @platform_mappings = nil
      end

      def platform? value
        return true if platform_mappings[value]
        platform_mappings[@platform].include? value
      end
    end
  end
end

module GTK
  class Runtime
    include Platform
  end
end
