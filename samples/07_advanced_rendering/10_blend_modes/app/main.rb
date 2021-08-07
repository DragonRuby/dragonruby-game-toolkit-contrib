$gtk.reset

def draw_blendmode args, mode
  w = 160
  h = w
  args.state.x += (1280-w) / (args.state.blendmodes.length + 1)
  x = args.state.x
  y = (720 - h) / 2
  s = 'sprites/blue-feathered.png'
  args.outputs.sprites << { blendmode_enum: mode.value, x: x, y: y, w: w, h: h, path: s }
  args.outputs.labels << [x + (w/2), y, mode.name.to_s, 1, 1, 255, 255, 255]
end

def tick args

  # Different blend modes do different things, depending on what they
  # blend against (in this case, the pixels of the background color).
  args.state.bg_element ||= 1
  args.state.bg_color ||= 255
  args.state.bg_color_direction ||= 1
  bg_r = (args.state.bg_element == 1) ? args.state.bg_color : 0
  bg_g = (args.state.bg_element == 2) ? args.state.bg_color : 0
  bg_b = (args.state.bg_element == 3) ? args.state.bg_color : 0
  args.state.bg_color += args.state.bg_color_direction
  if (args.state.bg_color_direction > 0) && (args.state.bg_color >= 255)
    args.state.bg_color_direction = -1
    args.state.bg_color = 255
  elsif (args.state.bg_color_direction < 0) && (args.state.bg_color <= 0)
    args.state.bg_color_direction = 1
    args.state.bg_color = 0
    args.state.bg_element += 1
    if args.state.bg_element >= 4
      args.state.bg_element = 1
    end
  end

  args.outputs.background_color = [ bg_r, bg_g, bg_b, 255 ]

  args.state.blendmodes ||= [
    { name: :none,  value: 0 },
    { name: :blend, value: 1 },
    { name: :add,   value: 2 },
    { name: :mod,   value: 3 },
    { name: :mul,   value: 4 }
  ]

  args.state.x = 0  # reset this, draw_blendmode will increment it.
  args.state.blendmodes.each { |blendmode| draw_blendmode args, blendmode }
end
