# coding: utf-8
# Copyright 2020 DragonRuby LLC
# MIT License
# args_docs.rb has been released under MIT (*only this file*).

module ArgsDocs
  def docs_method_sort_order
    [
      :docs_audio,
      :docs_easing,
      :docs_pixel_array,
      :docs_cvars
    ]
  end

  def docs_cvars
    <<-S
* CVars (~args.cvars~)

Hash contains metadata pulled from the files under the ~./metadata~ directory. To get the
keys that are available type ~$args.cvars.keys~ in the Console. Here is an example of how
to retrieve the game version number:

#+begin_src
  def tick args
    args.outputs.labels << {
      x: 640,
      y: 360,
      text: args.cvars["game_metadata.version"].value.to_s
    }
  end
#+end_src

Each CVar has the following properties ~value~, ~name~, ~description~, ~type~, ~locked~.
S
  end

  def docs_audio
    <<-S
* Audio (~args.audio~)

Hash that contains audio sources that are playing.

Sounds that don't specify ~looping: true~ will be removed automatically from
the hash after the playback ends. Looping sounds or sounds that should
stop early must be removed manually.

When you assign a hash to an audio output, a ~:length~ key will be
added to the hash on the following tick. This will tell you the
duration of the audio file in seconds (float).

** ~volume~

You can globally control the volume for all audio using ~args.audio.volume~. Example:

#+begin_src
  def tick args
    if args.inputs.down
      args.audio.volume -= 0.01
    elsif args.inputs.up
      args.audio.volume += 0.01
    end
  end
#+end_src

** One-Time Sounds

Here's how to play audio one-time (does not loop).

#+begin_src
  def tick args
    # play a one-time non-looping sound every second
    if (args.state.tick_count % 60) == 0
      args.audio[:coin] = { input: "sounds/coin.wav" }
      # OR
      args.outputs.sounds << "sounds/coin.wav"
    end
  end
#+end_src

** Looping Audio

Here's how to play audio that loops (eg background music), and how to stop the sound.

#+begin_src
  def tick args
    if args.state.tick_count == 0
      args.audio[:bg_music] = { input: "sounds/bg-music.ogg", looping: true }
    end

    # stop sound if space key is pressed
    if args.inputs.keyboard.key_down.space
      args.audio[:bg_music] = nil
      # OR
      args.audio.delete :bg_music
    end
  end
#+end_src

** Setting Additional Audio Properties

Here are additional properties that can be set.

#+begin_src
  def tick args
    # The values below (except for input of course) are the default values that apply if you don't
    # specify the value in the hash.
    args.audio[:my_audio] ||= {
      input: 'sound/boom.wav',  # file path relative to mygame directory
      gain:    1.0,             # Volume (float value 0.0 to 1.0)
      pitch:   1.0,             # Pitch of the sound (1.0 = original pitch)
      paused:  false,           # Set to true to pause the sound at the current playback position
      looping: true,            # Set to true to loop the sound/music until you stop it
      foobar:  :baz,            # additional keys/values can be safely added to help with context/game logic (ie metadata)
      x: 0.0, y: 0.0, z: 0.0    # Relative position to the listener, x, y, z from -1.0 to 1.0
    }
  end
#+end_src

IMPORTANT: Please take note that ~gain~ and ~pitch~ must be given ~float~ values (eg ~gain: 1.0~, not ~gain: 1~ or ~game: 0~).

** Advanced Audio Manipulation (Crossfade)

Take a look at the Audio Mixer sample app for a non-trival example of how to use these properties. The
sample app is located within the DragonRuby zip file at ~./samples/07_advanced_audio/01_audio_mixer~.

Here's an example of crossfading two bg music tracks.

#+begin_src
  def tick args
    # start bg-1.ogg at the start
    if args.state.tick_count == 0
      args.audio[:bg_music] = { input: "sounds/bg-1.ogg", looping: true, gain: 0.0 }
    end

    # if space is pressed cross fade to new bg music
    if args.inputs.keyboard.key_down.space
      # get the current bg music and create a new audio entry that represents the crossfade
      current_bg_music = args.audio[:bg_music]

      # cross fade audio entry
      args.audio[:bg_music_fade] = {
        input:    current_bg_music[:input],
        looping:  true,
        gain:     current_bg_music[:gain],
        pitch:    current_bg_music[:pitch],
        paused:   false,
        playtime: current_bg_music[:playtime]
      }

      # replace the current playing background music (toggling between bg-1.ogg and bg-2.ogg)
      # set the gain/volume to 0.0 (this will be increased to 1.0 accross ticks)
      new_background_music = { looping: true, gain: 0.0 }

      # determine track to play (swap between bg-1 and bg-2)
      new_background_music[:input] = if current_bg_music.input == "sounds/bg-1.ogg"
                                       "sounds/bg-2.ogg"
                                     else
                                       "sounds/bg-2.ogg"
                                     end

      # bg music audio entry
      args.audio[:bg_music] = new_background_music
    end

    # process cross fade (happens every tick)
    # increase the volume of bg_music every tick until it's at 100%
    if args.audio[:bg_music] && args.audio[:bg_music].gain < 1.0
      # increase the gain 1% every tick until we are at 100%
      args.audio[:bg_music].gain += 0.01
      # clamp value to 1.0 max value
      args.audio[:bg_music].gain = 1.0 if args.audio[:bg_music].gain > 1.0
    end

    # decrease the volume of cross fade bg music until it's 0.0, then delete it
    if args.audio[:bg_music_fade] && args.audio[:bg_music_fade].gain > 0.0
      # decrease by 1% every frame
      args.audio[:bg_music_fade].gain -= 0.01
      # delete audio when it's at 0%
      if args.audio[:bg_music_fade].gain <= 0.0
        args.audio[:bg_music_fade] = nil
      end
    end
  end
#+end_src

** Audio encoding trouble shooting

If audio doesn't seem to be working, try re-encoding it via ~ffmpeg~:

#+begin_src
  # re-encode ogg
  ffmpeg -i ./mygame/sounds/SOUND.ogg -ac 2 -b:a 160k -ar 44100 -acodec libvorbis ./mygame/sounds/SOUND-converted.ogg

  # convert wav to ogg
  ffmpeg -i ./mygame/sounds/SOUND.wav -ac 2 -b:a 160k -ar 44100 -acodec libvorbis ./mygame/sounds/SOUND-converted.ogg
#+end_src

** Audio synthesis

Instead of a path to an audio file you can specify an array ~[channels, sample_rate, sound_source]~ for ~input~
to procedurally generate sound. You do this by providing an array of float values between -1.0 and 1.0 that
describe the waveform you want to play.

- ~channels~ is the number of channels: 1 = mono, 2 = stereo
- ~sample_rate~ is the number of values per seconds you will provide to describe the audio wave
- ~sound_source~ The source of your sound. See below

*** Sound source

A sound source can be one of two things:

- A ~Proc~ object that is called on demand to generate the next samples to play. Every call should generate
  enough samples for at least 0.1 to 0.5 seconds to get continuous playback without audio skips.
  The audio will continue playing endlessly until removed, so the ~looping~ option will have no effect.

- An array of sample values that will be played back once. This is useful for procedurally generated one-off SFX.
  ~looping~ will work as expected

When you specify 2 for ~channels~, then the generated sample array will be played back in an interleaved manner.
The first element is the first sample for the left channel, the second element is the first sample for the right
channel, the third element is the second sample for the left channel etc.

*** Example:

#+begin_src
  def tick args
    sample_rate = 48000

    generate_sine_wave = lambda do
      frequency = 440.0 # A5
      samples_per_period = (sample_rate / frequency).ceil
      one_period = samples_per_period.map_with_index { |i|
        Math.sin((2 * Math::PI) * (i / samples_per_period))
      }
      one_period * frequency # Generate 1 second worth of sound
    end

    args.audio[:my_audio] ||= {
      input: [1, sample_rate, generate_sine_wave]
    }
  end
#+end_src

S
  end

  def docs_easing
    <<-S
* Easing (~args.easing~)
A set of functions that allow you to determine the current progression of an easing function.

** ~ease~
This function will give you a float value between ~0~ and ~1~ that represents a percentage. You need to give the
funcation a ~start_tick~, ~current_tick~, duration, and easing ~definitions~.

This YouTube video is a fantastic introduction to easing functions: [[https://www.youtube.com/watch?v=mr5xkf6zSzk]]

*** Examples

This example shows how to fade in a label at frame 60 over two seconds (120 ticks). The ~:identity~ definition
implies a linear fade: ~f(x) -> x~.

#+begin_src
  def tick args
    fade_in_at   = 60
    current_tick = args.state.tick_count
    duration     = 120
    percentage   = args.easing.ease fade_in_at,
                                    current_tick,
                                    duration,
                                    :identity
    alpha = 255 * percentage
    args.outputs.labels << { x: 640,
                             y: 320, text: "\#{percentage.to_sf}",
                             alignment_enum: 1,
                             a: alpha }
  end
#+end_src

This example will move a box at a linear speed from 0 to 1280.

#+begin_src ruby
  def tick args
    start_time = 10
    duration = 60
    current_progress = args.easing.ease start_time,
                                        args.state.tick_count,
                                        duration,
                                        :identity
    args.outputs.solids << { x: 1280 * current_progress, y: 360, w: 10, h: 10 }
  end
#+end_src

*** Easing Definitions
There are a number of easing definitions availble to you:

**** ~:identity~
The easing definition for ~:identity~ is ~f(x) = x~. For example, if ~start_tick~ is ~0~, ~current_tick~ is ~50~, and
~duration~ is ~100~, then ~args.easing.ease 0, 50, 100, :identity~ will return ~0.5~ (since tick ~50~ is half way between ~0~
and ~100~).

**** ~:flip~
The easing definition for ~:flip~ is ~f(x) = 1 - x~. For example, if ~start_tick~ is ~0~, ~current_tick~ is ~10~, and
~duration~ is ~100~, then ~args.easing.ease 0, 10, 100, :flip~ will return ~0.9~ (since tick ~10~ means 100% - 10%).

**** ~:quad~, ~:cube~, ~:quart~, ~:quint~
These are the power easing definitions. ~:quad~ is ~f(x) = x * x~ (~x~ squared), ~:cube~ is ~f(x) = x * x * x~  (~x~ cubed), etc.

The power easing definitions represent Smooth Start easing (the percentage changes slow at first and speeds up at the end).

***** Example
Here is an example of Smooth Start (the percentage changes slow at first and speeds up at the end).

#+begin_src
  def tick args
    start_tick   = 60
    current_tick = args.state.tick_count
    duration     = 120
    percentage   = args.easing.ease start_tick,
                                    current_tick,
                                    duration,
                                    :quad
    start_x      = 100
    end_x        = 1180
    distance_x   = end_x - start_x
    final_x      = start_x + (distance_x * percentage)

    start_y      = 100
    end_y        = 620
    distance_y   = end_y - start_y
    final_y      = start_y + (distance_y * percentage)

    args.outputs.labels << { x: final_x,
                             y: final_y,
                             text: "\#{percentage.to_sf}",
                             alignment_enum: 1 }
  end
#+end_src

**** Combining Easing Definitions
The base easing definitions can be combined to create common easing functions.

***** Example
Here is an example of Smooth Stop (the percentage changes fast at first and slows down at the end).

#+begin_src
  def tick args
    start_tick   = 60
    current_tick = args.state.tick_count
    duration     = 120

    # :flip, :quad, :flip is Smooth Stop
    percentage   = args.easing.ease start_tick,
                                    current_tick,
                                    duration,
                                    :flip, :quad, :flip
    start_x      = 100
    end_x        = 1180
    distance_x   = end_x - start_x
    final_x      = start_x + (distance_x * percentage)

    start_y      = 100
    end_y        = 620
    distance_y   = end_y - start_y
    final_y      = start_y + (distance_y * percentage)

    args.outputs.labels << { x: final_x,
                             y: final_y,
                             text: "\#{percentage.to_sf}",
                             alignment_enum: 1 }
  end
#+end_src

**** Custom Easing Functions
You can define your own easing functions by passing in a ~lambda~ as a ~definition~ or extending
the ~Easing~ module.

***** Example - Using Lambdas
This easing function goes from ~0~ to ~1~ for the first half of the ease, then ~1~ to ~0~ for
the second half of the ease.

#+begin_src
  def tick args
    fade_in_at    = 60
    current_tick  = args.state.tick_count
    duration      = 600
    easing_lambda = lambda do |percentage, start_tick, duration|
                      fx = percentage
                      if fx < 0.5
                        fx = percentage * 2
                      else
                        fx = 1 - (percentage - 0.5) * 2
                      end
                      fx
                    end

    percentage    = args.easing.ease fade_in_at,
                                     current_tick,
                                     duration,
                                     easing_lambda

    alpha = 255 * percentage
    args.outputs.labels << { x: 640,
                             y: 320,
                             a: alpha,
                             text: "\#{percentage.to_sf}",
                             alignment_enum: 1 }
  end
#+end_src

***** Example - Extending Easing Definitions
If you don't want to create a lambda, you can register an easing definition like so:

#+begin_src
  # 1. Extend the Easing module
  module Easing
    def self.saw_tooth x
      if x < 0.5
        x * 2
      else
        1 - (x - 0.5) * 2
      end
    end
  end

  def tick args
    fade_in_at    = 60
    current_tick  = args.state.tick_count
    duration      = 600

    # 2. Reference easing definition by name
    percentage    = args.easing.ease fade_in_at,
                                     current_tick,
                                     duration,
                                     :saw_tooth

    alpha = 255 * percentage
    args.outputs.labels << { x: 640,
                             y: 320,
                             a: alpha,
                             text: "\#{percentage.to_sf}",
                             alignment_enum: 1 }

  end
#+end_src

*** ~easing.ease_spline start_tick, current_tick, duration, spline~
Given a start, current, duration, and a multiple bezier values, this function returns a number between 0 and 1 that represents the progress of an easing function.

This example will move a box at a linear speed from 0 to 1280 and then back to 0 using two bezier definitions (represented as an array with four values).

#+begin_src ruby
  def tick args
    start_time = 10
    duration = 60
    spline = [
      [  0, 0.25, 0.75, 1.0],
      [1.0, 0.75, 0.25,   0]
    ]
    current_progress = args.easing.ease_spline start_time,
                                               args.state.tick_count,
                                               duration,
                                               spline
    args.outputs.solids << { x: 1280 * current_progress, y: 360, w: 10, h: 10 }
  end
#+end_src
S
  end

  def docs_pixel_array
    <<-S
* Pixel Arrays (~args.pixel_arrays~)

A ~PixelArray~ object with a width, height and an Array of pixels which are hexadecimal color values in ABGR format.

You can create a pixel array like this:

#+begin_src
  w = 200
  h = 100
  args.pixel_array(:my_pixel_array).w = w
  args.pixel_array(:my_pixel_array).h = h
#+end_src

You'll also need to fill the pixels with values, if they are ~nil~, the array will render with the checkerboard texture.  You can use #00000000 to fill with transparent pixels if desired.

#+begin_src
  args.pixel_array(:my_pixel_array).pixels.fill #FF00FF00, 0, w * h
#+end_src

Note: To convert from rgb hex (like skyblue #87CEEB) to abgr hex, you split it in pairs pair (eg ~87~ ~CE~ ~EB~) and reverse the order (eg ~EB~ ~CE~ ~87~) add join them again: ~#EBCE87~. Then add the alpha component in front ie: ~FF~ for full opacity: ~#FFEBCE87~.

You can draw it by using the symbol for ~:path~

#+begin_src
  args.outputs.sprites << { x: 500, y: 300, w: 200, h: 100, path: :my_pixel_array) }
#+end_src

If you want access a specific x, y position, you can do it like this for a bottom-left coordinate system:

#+begin_src
  x = 150
  y = 33
  args.pixel_array(:my_pixel_array).pixels[(height - y) * width + x] = 0xFFFFFFFF
#+end_src

** Related Sample Apps

- Animation using pixel arrays: ~./samples/07_advanced_rendering/06_pixel_arrays~
- Load a pixel array from a png: ~./samples/07_advanced_rendering/06_pixel_arrays_from_file/~
S
  end
end

class GTK::Args
  extend Docs
  extend ArgsDocs
end
