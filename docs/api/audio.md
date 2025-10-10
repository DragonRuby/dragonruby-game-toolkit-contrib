# Audio (`args.audio`)

Hash that contains audio sources that are playing.

Sounds that don't specify `looping: true` will be removed automatically from the hash after the playback ends. Looping sounds or sounds that should stop early must be removed manually.

When you assign a hash to an audio output, a `:length` key will be added to the hash on the following tick. This will tell you the duration of the audio file in seconds (float).

## `volume`

You can globally control the volume for all audio using `args.audio.volume`. Example:

```ruby
def tick args
  if args.inputs.down
    args.audio.volume -= 0.01
  elsif args.inputs.up
    args.audio.volume += 0.01
  end
end
```

## One-Time Sounds

Here's how to play audio one-time (does not loop).

```ruby
def tick args
  # play a one-time non-looping sound every second
  if (Kernel.tick_count % 60) == 0
    args.audio[:coin] = { input: "sounds/coin.wav" }
    # OR
    args.outputs.sounds << "sounds/coin.wav"
  end
end
```

?> `.wav` files can have a maximum sample rate of 44.1kHz. You can use `ffmpeg` to resample audio. Eg: `ffmpeg -i input.wav -ar 44100 output.wav`.

## Looping Audio

Here's how to play audio that loops (eg background music), and how to stop the sound.

```ruby
def tick args
  if Kernel.tick_count == 0
    args.audio[:bg_music] = { input: "sounds/bg-music.ogg", looping: true }
  end

  # stop sound if space key is pressed
  if args.inputs.keyboard.key_down.space
    args.audio[:bg_music] = nil
    # OR
    args.audio.delete :bg_music
  end
end
```

## Setting Additional Audio Properties

Here are additional properties that can be set.

```ruby
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
```

Once an audio track has been loaded, the follow properties will be added to the hash:

- `playtime`: Represents the current position of the play head (a `float` value measured in seconds).
- `playlength`: Represents the length of the track (a `float` value measured in seconds).

IMPORTANT: Please take note that `gain` and `pitch` must be given `float` values (eg `gain: 1.0`, not `gain: 1` or `game: 0`).

## Advanced Audio Manipulation (Crossfade)

Take a look at the Audio Mixer sample app for a non-trivial example of how to use these properties. The sample app is located within the DragonRuby zip file at `./samples/07_advanced_audio/01_audio_mixer`.

Here's an example of crossfading two bg music tracks.

```ruby
def tick args
  # start bg-1.ogg at the start
  if Kernel.tick_count == 0
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
                                     "sounds/bg-1.ogg"
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
```

Here's an example of crossfading for a list of songs:

```ruby
def tick args
  # play list of songs in order
  args.state.playlist ||= [
    { input: "sounds/music.ogg", },
    { input: "sounds/music_2.ogg", },
    { input: "sounds/music_3.ogg" }
  ]

  if Kernel.tick_count == 0
    # on first tick, create a data structure that correlates
    # the current song with the next song using Ruby's
    # Enumerable#each_cons (each consecutive 2)
    args.state.playlist.each_cons(2) do |c, n|
      # create a unique id for the current song
      # (this will be the key for the audio hash)
      c.id = GTK.create_uuid
      # set the next song for the current song
      c.next_song = n
    end

    # queue the first song to start playing (gain of zero)
    first_song = args.state.playlist.first
    args.audio[first_song.id] = { input: first_song.input,
                                  gain: 0,
                                  next_song: first_song.next_song }
  end

  # every tick, check the audio hash
  args.audio.each do |k, v|
    # if the playlength hasn't been loaded, skip processing for now
    next if !v.playlength

    # given the playtime, set when the fadeout should start
    # (3 seconds before the end)
    v.fadeout_at ||= v.playlength - 3

    # if the current playtime is less than the
    # fadeout time, increase the volume
    if v.playtime < v.fadeout_at
      v.gain += 1.fdiv(180)
    else
      # otherwise decrease the volume over 3 seconds to zero and
      # determine if the next song should be queued
      v.gain -= 1.fdiv(180)

      # if the next song hasn't been queued and
      # there is a next song, queue it
      if v.next_song && !v.next_song_queued
        song_to_queue = v.next_song
        args.audio[song_to_queue.id] = {
          input: song_to_queue.input,
          gain:  0,
          next_song: song_to_queue.next_song
        }

        # set a flag on the current song to indicate
        # that the next song has been queued
        v.next_song_queued = true
      end
    end

    v.gain = v.gain.clamp(0, 1.0)
  end

  # display audio information
  args.audio.each do |k, v|
    args.outputs.watch "song #{v.input}"
    args.outputs.watch "  gain #{v.gain}"
    args.outputs.watch "  playlength #{v.playlength}"
    args.outputs.watch "  playtime #{v.playtime}"
    args.outputs.watch "  fadeout_at #{v.fadeout_at}"
    args.outputs.watch "  next_song_queued #{!!v.next_song_queued}"
    args.outputs.watch "  has_next_song #{!!v.next_song}"
    if v.next_song
      args.outputs.watch "  next_song #{v.next_song.input}"
    end
  end
end
```

## Audio encoding trouble shooting

If audio doesn't seem to be working, try re-encoding it via `ffmpeg`:

```sh
# re-encode ogg
ffmpeg -i ./mygame/sounds/SOUND.ogg -ac 2 -b:a 160k -ar 44100 -acodec libvorbis ./mygame/sounds/SOUND-converted.ogg

# convert wav to ogg
ffmpeg -i ./mygame/sounds/SOUND.wav -ac 2 -b:a 160k -ar 44100 -acodec libvorbis ./mygame/sounds/SOUND-converted.ogg
```

## Sound Synthesis

Instead of a path to an audio file you can specify an array `[channels, sample_rate, sound_source]` for `input` to procedurally generate sound. You do this by providing an array of float values between -1.0 and 1.0 that describe the waveform you want to play.

-   `channels` is the number of channels: 1 = mono, 2 = stereo
-   `sample_rate` is the number of values per seconds you will provide to describe the audio wave
-   `sound_source` The source of your sound. See below

### Sound Source

A sound source can be one of two things:

-   A `Proc` object that is called on demand to generate the next samples to play. Every call should generate enough samples for at least 0.1 to 0.5 seconds to get continuous playback without audio skips. The audio will continue playing endlessly until removed, so the `looping` option will have no effect.

-   An array of sample values that will be played back once. This is useful for procedurally generated one-off SFX. `looping` will work as expected

When you specify 2 for `channels`, then the generated sample array will be played back in an interleaved manner. The first element is the first sample for the left channel, the second element is the first sample for the right channel, the third element is the second sample for the left channel etc.

For sound synthesis, `gain` can be initially set, but changing the value while the sound is playing will produce clicking/popping sounds. The attack and release of the sound should be baked into the array.

### Example:

```ruby
def generate_sine_wave frequency:, duration:, fade_out: true
  samples_per_period = (48000 / frequency).ceil
  count = (samples_per_period * duration.fdiv(60)).floor * frequency
  count.map_with_index do |i|
    attack_perc = (i / samples_per_period).clamp(0, 1)
    release_perc = if fade_out
                      1 - (i / count)
                   elsif i > count - samples_per_period
                     (count - i) / samples_per_period
                   else
                     1
                   end
    Math.sin((2 * Math::PI) * (i / samples_per_period)) * attack_perc * release_perc
  end
end

def tick args
  if Kernel.tick_count == 0
    wave_data = generate_sine_wave frequency: 440.0,
                                   duration: 60 * 1.5,
                                   fade_out: true
    args.audio[:my_audio] = {
      input: [1, 48000, wave_data],
    }
  end
end
```
