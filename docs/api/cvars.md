# CVars (`args.cvars`)

Hash contains metadata pulled from the files under the `./metadata` directory. To get the keys that are available type `$args.cvars.keys` in the Console. Here is an example of how to retrieve the game version number:

```ruby
def tick args
  args.outputs.labels << {
    x: 640,
    y: 360,
    text: args.cvars["game_metadata.version"].value.to_s
  }
end
```

Each CVar has the following properties `value`, `name`, `description`, `type`, `locked`.
