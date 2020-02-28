# Documentation That Needs to be Organized

## Class macro gtk_args

Here's how you can use the `gtk_args` class method:

```ruby
class Game
  gtk_args
  attr_accessor :current_scene, :other_custom_attrs

  def tick
  end
end

$game = Game.new

def tick args
  $game.args = args
  $game.tick
end
```

The code above is the similar to:

```ruby
class Game
  attr_accessor :args, :grid, :state, :inputs, :outputs, :gtk, :passes,
                :current_scene, :other_custom_attrs

  def tick
  end
end

$game = Game.new

def tick args
  $game.args    = args
  $game.grid    = args.grid
  $game.state   = args.state
  $game.outputs = args.outputs
  $game.gtk     = args.gtk
  $game.passes  = args.passes
  $game.tick
end
```

## Monkey patching the runtime

You're on your own if you do this :grimacing:

```ruby
module GTK
  class Runtime
    alias_method :__original_tick_core__, :tick_core unless Runtime.instance_methods.include?(:__original_tick_core__)

    def tick_core
      __original_tick_core__
      $top_level.oh @args
      $top_level.god @args
      $top_level.why @args
    end
  end
end

def tick args
end

def oh args
end

def god args
end

def why args
end
```

## MP3's to Wav converstion script:

```ruby
`ls .`.each_line.to_a.map do |l|
  l = l.strip
  if l.end_with? "mp3"
    `ffmpeg -i #{l} -acodec pcm_s16le -ar 44100 prep-#{l.split(".")[0]}.wav`
    `ffmpeg -y -i prep-#{l.split(".")[0]}.wav -f wav -bitexact -acodec pcm_s16le -ar 44100 -ac 1 #{l.split(".")[0]}.wav`
  end
end
```
