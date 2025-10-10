# State (`args.state`)

`args.state` is a property bag that can be used to hold state for your
game. It's useful for rapid prototyping, especially when you're not ready to
commit to using classes. Values in `args.state` are retained across
invocations of the `tick` method. Values within `args.state` are automatically cleared
if `GTK.reset` is invoked.

For rapid prototyping (without using classes). It's recommended to use
`args.state` as opposed to `iVars` (class-less `iVars` will pollute the
global object space and would not be cleared via `GTK.reset`). 

To use `args.state`, you'll need to initialize it to an empty `Hash` within `boot`. 

?> While this initializing step isn't currently required, future
versions of DragonRuby will enforce `args.state` initialization during `boot`.

```ruby
def boot args
  args.state = {}
end

def tick args
  args.state.player ||= {
    x: 0,
    y: 0
  }
  
  args.state.player.x += 1
  args.state.player.y += 1
  
  # DON'T use "bare iVars" because it would pollute the global
  # object space. BAD (don't do this):
  # @player ||= { x: 0, y: 0 }
  
  args.outputs.labels << {
    x: 640,
    y: 360,
    text: "player's x, y: #{args.state.player.x}, #{args.state.player.x}",
    anchor_x: 0.5,
    anchor_y: 0.5
  }
end
```

Opening up the DragonRuby Console and invoking `GTK.reset` will clear
out the values in `args.state` automatically. You can also directly
access `args.state` information from within the console using the
`$state` global variable. It's recommended that you use the global
`$state` for debugging purposes only (using a bunch of global
variables everywhere can lead to spaghetti code).

## Using iVars instead of `args.state`

If you are using classes and the `attr_gtk` class macro, `args.state`
usage is optional (though still available). Resetting game state that
isn't housed in `args.state` requires you to provide a `reset`
function at the top level.

The `args.state` is essentially a singleton. You may opt to use
classes and `iVars` over `args.state` so you don't unnecessarily "over share" data
across your game components (it's a bit more code but more
maintainable long term).

```ruby
class Game
  attr_gtk
  
  def initialize
  end
  
  def tick
    @player ||= { x: 0, y: 0 }
    @player.x += 1
    @player.y += 1
    
    # this is still available to use
    # state.player ||= { x: 0, y: 0 }
    # state.player.x += 1
    # state.player.y += 1

    outputs.labels << {
      x: 640,
      y: 360,
      text: "player's x, y: #{@player.x} #{@player.x}",
      anchor_x: 0.5,
      anchor_y: 0.5
    }
  end
end

def boot args
  args.state = {}
end

def tick args
  $game ||= Game.new
  $game.args = args
  $game.tick
end

def reset args
  $game = nil
end
```

?> In short, use `args.state` for rapid prototyping, use `iVars` +
classes for long term maintainability, and use `$state` for debugging
purposes only.
