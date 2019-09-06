def tick args
  args.outputs.labels << [ 580, 500, 'Hello World!' ]
  args.outputs.labels << [ 475, 150, '(Consider reading README.txt now.)' ]
  args.outputs.sprites << [ 576, 310, 128, 101, 'dragonruby.png' ]
end

