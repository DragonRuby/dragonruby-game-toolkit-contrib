# This sample is meant to show you how to do that dripping transition thing
#  at the start of the original Doom. Most of this file is here to animate
#  a scene to wipe away; the actual wipe effect is in the last 20 lines or
#  so.

$gtk.reset   # reset all game state if reloaded.

def circle_of_blocks pass, xoffset, yoffset, angleoffset, blocksize, distance
  numblocks = 10

  for i in 1..numblocks do
    angle = ((360 / numblocks) * i) + angleoffset
    radians = angle * (Math::PI / 180)
    x = (xoffset + (distance * Math.cos(radians))).round
    y = (yoffset + (distance * Math.sin(radians))).round
    pass.solids << [ x, y, blocksize, blocksize, 255, 255, 0 ]
  end
end

def draw_scene args, pass
  pass.solids << [0, 360, 1280, 360, 0, 0, 200]
  pass.solids << [0, 0, 1280, 360, 0, 127, 0]

  blocksize = 100
  angleoffset = args.state.tick_count * 2.5
  centerx = (1280 - blocksize) / 2
  centery = (720 - blocksize) / 2

  circle_of_blocks pass, centerx, centery, angleoffset, blocksize * 2, 500
  circle_of_blocks pass, centerx, centery, angleoffset, blocksize, 325
  circle_of_blocks pass, centerx, centery, angleoffset, blocksize / 2, 200
  circle_of_blocks pass, centerx, centery, angleoffset, blocksize / 4, 100
end

def tick args
  segments = 160

  # On the first tick, initialize some stuff.
  if !args.state.yoffsets
    args.state.baseyoff = 0
    args.state.yoffsets = []
    for i in 0..segments do
      args.state.yoffsets << rand * 100
    end
  end

  # Just draw some random stuff for a few seconds.
  args.state.static_debounce ||= 60 * 2.5
  if args.state.static_debounce > 0
    last_frame = args.state.static_debounce == 1
    target = last_frame ? args.render_target(:last_frame) : args.outputs
    draw_scene args, target
    args.state.static_debounce -= 1
    return unless last_frame
  end

  # build up the wipe...

  # this is the thing we're wiping to.
  args.outputs.sprites << [ 0, 0, 1280, 720, 'dragonruby.png' ]

  return if (args.state.baseyoff > (1280 + 100))  # stop when done sliding

  segmentw = 1280 / segments

  x = 0
  for i in 0..segments do
    yoffset = 0
    if args.state.yoffsets[i] < args.state.baseyoff
      yoffset = args.state.baseyoff - args.state.yoffsets[i]
    end

    # (720 - yoffset) flips the coordinate system, (- 720) adjusts for the height of the segment.
    args.outputs.sprites << [ x, (720 - yoffset) - 720, segmentw, 720, 'last_frame', 0, 255, 255, 255, 255, x, 0, segmentw, 720 ]
    x += segmentw
  end

  args.state.baseyoff += 4

  tick_instructions args, "Sample app shows an advanced usage of render_target."
end

def tick_instructions args, text, y = 715
  return if args.state.key_event_occurred
  if args.inputs.mouse.click ||
     args.inputs.keyboard.directional_vector ||
     args.inputs.keyboard.key_down.enter ||
     args.inputs.keyboard.key_down.escape
    args.state.key_event_occurred = true
  end

  args.outputs.debug << [0, y - 50, 1280, 60].solid
  args.outputs.debug << [640, y, text, 1, 1, 255, 255, 255].label
  args.outputs.debug << [640, y - 25, "(click to dismiss instructions)" , -2, 1, 255, 255, 255].label
end
