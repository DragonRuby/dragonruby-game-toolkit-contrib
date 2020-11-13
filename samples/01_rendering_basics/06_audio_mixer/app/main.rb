$gtk.reset

$boxsize = 30

def render_sources args
  mouse_in_panel = (args.state.selected != 0) && args.inputs.mouse.position.inside_rect?([900, 450, 340, 250])
  mouse_new_down = (args.state.mouse_held == 1)

  if (mouse_new_down && !mouse_in_panel)
    args.state.selected = 0  # will reset below if we hit something.
  end

  args.audio.keys.each { |k|
    s = args.audio[k]

    if (mouse_new_down) && !mouse_in_panel && args.inputs.mouse.position.inside_rect?([s[:screenx], s[:screeny], $boxsize, $boxsize])
      args.state.selected = k
      args.state.dragging_source = true
    end

    isselected = (k == args.state.selected)

    if isselected && args.state.dragging_source
      # you can hang anything on the audio hashes you want, so we store the
      #  actual screen position so it doesn't scale weirdly vs your mouse.
      s[:screenx] = args.inputs.mouse.x - ($boxsize / 2)
      s[:screeny] = args.inputs.mouse.y - ($boxsize / 2)

      s[:screeny] = 50 if s[:screeny] < 50
      s[:screeny] = (719 - $boxsize) if s[:screeny] > (719 - $boxsize)
      s[:screenx] = 0 if s[:screenx] < 0
      s[:screenx] = (1279 - $boxsize) if s[:screenx] > (1279 - $boxsize)

      s[:x] = ((s[:screenx] / 1279.0) * 2.0) - 1.0  # scale to -1.0 - 1.0 range
      s[:y] = ((s[:screeny] / 719.0) * 2.0) - 1.0   # scale to -1.0 - 1.0 range
    end

    color = isselected ? [ 0, 255, 0, 255 ] : [ 0, 0, 255, 255 ]
    args.outputs.primitives << [s[:screenx], s[:screeny], $boxsize, $boxsize, *color].solid
  }
end

def render_panel args
  s = args.audio[args.state.selected]
  return if s.nil?
  mouse_down = (args.state.mouse_held > 0)

  args.outputs.primitives << [900, 450, 340, 250, 127, 127, 200, 255].solid
  args.outputs.primitives << [1075, 690, "Source ##{args.state.selected}", 3, 1, 255, 255, 255].label
  args.outputs.primitives << [910, 660, 1230, 660, 255, 255, 255].line
  args.outputs.primitives << [910, 650, "screen:    (#{s[:screenx].to_i}, #{s[:screeny].to_i})", 0, 0, 255, 255, 255].label
  args.outputs.primitives << [910, 625, "position:  (#{s[:x].round(5).to_s[0..6]}, #{s[:y].round(5).to_s[0..6]})", 0, 0, 255, 255, 255].label

  slider = [1022, 586, 200, 7]
  if mouse_down && args.inputs.mouse.position.inside_rect?(slider)
    s[:pitch] = ((args.inputs.mouse.x - slider[0]).to_f / (slider[2]-1.0)) * 2.0
  end
  slidercolor = (s[:pitch] / 2.0) * 255
  args.outputs.primitives << [*slider, slidercolor, slidercolor, slidercolor, 255].solid
  args.outputs.primitives << [910, 600, "pitch: #{s[:pitch].round(3).to_s[0..2]}", 0, 0, 255, 255, 255].label

  slider = [1022, 561, 200, 7]
  if mouse_down && args.inputs.mouse.position.inside_rect?(slider)
    s[:gain] = (args.inputs.mouse.x - slider[0]).to_f / (slider[2]-1.0)
  end
  slidercolor = s[:gain] * 255
  args.outputs.primitives << [*slider, slidercolor, slidercolor, slidercolor, 255].solid
  args.outputs.primitives << [910, 575, "gain: #{s[:gain].round(3).to_s[0..2]}", 0, 0, 255, 255, 255].label

  checkbox = [1022, 533, 10, 12]
  if (args.state.mouse_held == 1) && args.inputs.mouse.position.inside_rect?(checkbox)
    s[:looping] = !s[:looping]
  end
  checkboxcolor = s[:looping] ? 255 : 0
  args.outputs.primitives << [*checkbox, checkboxcolor, checkboxcolor, checkboxcolor, 255].solid
  args.outputs.primitives << [910, 550, "looping:", 0, 0, 255, 255, 255].label

  checkbox = [1022, 508, 10, 12]
  if (args.state.mouse_held == 1) && args.inputs.mouse.position.inside_rect?(checkbox)
    s[:paused] = !s[:paused]
  end
  checkboxcolor = s[:paused] ? 255 : 0
  args.outputs.primitives << [*checkbox, checkboxcolor, checkboxcolor, checkboxcolor, 255].solid
  args.outputs.primitives << [910, 525, "paused:", 0, 0, 255, 255, 255].label

  button = [910, 460, 320, 20]
  if (args.state.mouse_held == 1) && args.inputs.mouse.position.inside_rect?(button)
    args.audio.delete(args.state.selected)
    args.state.selected = 0
  end
  args.outputs.primitives << [*button, 255, 0, 0, 255].solid
  args.outputs.primitives << [button[0] + (button[2] / 2), button[1]+20, "DELETE SOURCE", 0, 1, 255, 255, 0].label
end

def spawn_new_sound args, num
  input = nil
  input = "sounds/#{num}.#{(num == 6) ? 'ogg' : 'wav'}"

  # Spawn randomly in an area that won't be covered by UI.
  screenx = (rand * 600.0) + 200.0
  screeny = (rand * 400.0) + 100.0

  args.state.next_sound_index += 1

  # you can hang anything on the audio hashes you want, so we store the
  #  actual screen position in here for convenience.
  args.audio[args.state.next_sound_index] = {
    input: input,
    screenx: screenx,
    screeny: screeny,
    x: ((screenx / 1279.0) * 2.0) - 1.0,  # scale to -1.0 - 1.0 range
    y: ((screeny / 719.0) * 2.0) - 1.0,   # scale to -1.0 - 1.0 range
    z: 0.0,
    gain: 1.0,
    pitch: 1.0,
    looping: true,
    paused: false
  }

  args.state.selected = args.state.next_sound_index
end

def render_launcher args
  total = 6
  x = (1280 - (total * $boxsize * 3)) / 2
  y = 10
  args.outputs.primitives << [0, 0, 1280, ((y*2) + $boxsize), 127, 127, 127, 255].solid
  for i in 1..total
    args.outputs.primitives << [x, y, $boxsize, $boxsize, 255, 255, 255, 255].solid
    args.outputs.primitives << [x+8, y+28, i.to_s, 3, 0, 0, 0, 255, 255].label
    if args.inputs.mouse.click && args.inputs.mouse.click.point.inside_rect?([x, y, $boxsize, $boxsize])
      spawn_new_sound args, i
    end
    x = x + ($boxsize * 3)
  end
end

def render_ui args
  render_launcher args
  render_panel args
end

def tick args
  args.state.mouse_held ||= 0
  args.state.dragging_source ||= false
  args.state.selected ||= 0
  args.state.next_sound_index ||= 0

  if args.inputs.mouse.up
    args.state.mouse_held = 0
    args.state.dragging_source = false
  elsif args.inputs.mouse.down || (args.state.mouse_held > 0)
    args.state.mouse_held += 1
  else
  end

  args.outputs.background_color = [ 0, 0, 0, 255 ]
  render_sources args
  render_ui args
end
