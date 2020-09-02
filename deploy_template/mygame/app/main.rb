def tick args
  args.outputs.labels << [ 580, 500, 'Hello World!' ]
  args.outputs.labels << [ 640, 460, 'Go to docs/docs.html and read it!', 5, 1 ]
  args.outputs.sprites << [ 576, 310, 128, 101, 'dragonruby.png' ]
end
