# General Stuff

- You have 1280x720 pixels to work with. The bottom left corner is 0, 0
  with X increasing going right, and Y increasing going up.
- The game is on a fixed 60 fps cycle (no delta time needed).
- Come to the Discord if you need help: http://discord.dragonruby.org
- Going through all the sample apps is a REALLY GOOD IDEA. Most sample apps
  contain a recorded replay/demo. So just double click `watch-recording` to
  see a full presentation of the sample.

# Entry Point

For all the examples in the other documentation files. It's assumed they
are being placed into the follow code block:

```
# Entry point placed in main.rb
def tick args
  args.outputs.labels << [100, 100, 'hello world']
end
```

# New to Ruby

If you are a complete beginner and have never coded before:

1. Run the 00_beginner_ruby_primer sample app and work through it.
   Video walkthrough: https://s3.amazonaws.com/s3.dragonruby.org/dragonruby-gtk-primer.mp4
2. Read all the code in the 00_intermediate_ruby_primer sample app.
   Video walkthrough: https://s3.amazonaws.com/s3.dragonruby.org/dragonruby-gtk-intermediate.mp4
3. There is also a free course you can sign up for at http://dragonruby.school
