# coding: utf-8
# Copyright 2020 DragonRuby LLC
# MIT License
# args_docs.rb has been released under MIT (*only this file*).

module ArgsDocs
  def docs_method_sort_order
    [
      :docs_audio
    ]
  end

  def docs_audio
    <<-S
* DOCS: ~GTK::Args#audio~

Hash that contains audio sources that are playing. If you want to add a new sound add a hash with keys/values as
in the following example:

#+begin_src
  def tick args
    # The values below (except for input of course) are the default values that apply if you don't
    # specify the value in the hash.
    args.audio[:my_audio] = {
      input: 'sound/boom.wav',  # Filename
      x: 0.0, y: 0.0, z: 0.0,   # Relative position to the listener, x, y, z from -1.0 to 1.0
      gain: 1.0,                # Volume (0.0 to 1.0)
      pitch: 1.0,               # Pitch of the sound (1.0 = original pitch)
      paused: false,            # Set to true to pause the sound at the current playback position
      looping: false,           # Set to true to loop the sound/music until you stop it
    }
  end
#+end_src

Sounds that don't specify ~looping: true~ will be removed automatically from the hash after the playback ends.
Looping sounds or sounds that should stop early must be removed manually.

** Audio synthesis (Pro only)

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
end

class GTK::Args
  extend Docs
  extend ArgsDocs
end
