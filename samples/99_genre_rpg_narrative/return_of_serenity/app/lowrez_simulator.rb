###################################################################################
# YOU CAN PLAY AROUND WITH THE CODE BELOW, BUT USE CAUTION AS THIS IS WHAT EMULATES
# THE 64x64 CANVAS.
###################################################################################

TINY_RESOLUTION       = 64
TINY_SCALE            = 720.fdiv(TINY_RESOLUTION + 5)
CENTER_OFFSET         = 10
EMULATED_FONT_SIZE    = 20
EMULATED_FONT_X_ZERO  = 0
EMULATED_FONT_Y_ZERO  = 46

def tick args
  sprites = []
  labels = []
  borders = []
  solids = []
  mouse = emulate_lowrez_mouse args
  args.state.show_gridlines = false
  lowrez_tick args, sprites, labels, borders, solids, mouse
  render_gridlines_if_needed args
  render_mouse_crosshairs args, mouse
  emulate_lowrez_scene args, sprites, labels, borders, solids, mouse
end

def emulate_lowrez_mouse args
  args.state.new_entity_strict(:lowrez_mouse) do |m|
    m.x = args.mouse.x.idiv(TINY_SCALE) - CENTER_OFFSET.idiv(TINY_SCALE) - 1
    m.y = args.mouse.y.idiv(TINY_SCALE)
    if args.mouse.click
      m.click = [
        args.mouse.click.point.x.idiv(TINY_SCALE) - CENTER_OFFSET.idiv(TINY_SCALE) - 1,
        args.mouse.click.point.y.idiv(TINY_SCALE)
      ]
      m.down = m.click
    else
      m.click = nil
      m.down = nil
    end

    if args.mouse.up
      m.up = [
        args.mouse.up.point.x.idiv(TINY_SCALE) - CENTER_OFFSET.idiv(TINY_SCALE) - 1,
        args.mouse.up.point.y.idiv(TINY_SCALE)
      ]
    else
      m.up = nil
    end
  end
end

def render_mouse_crosshairs args, mouse
  return unless args.state.show_gridlines
  args.labels << [10, 25, "mouse: #{mouse.x} #{mouse.y}", 255, 255, 255]
end

def emulate_lowrez_scene args, sprites, labels, borders, solids, mouse
  args.render_target(:lowrez).solids  << [0, 0, 1280, 720]
  args.render_target(:lowrez).sprites << sprites
  args.render_target(:lowrez).borders << borders
  args.render_target(:lowrez).solids  << solids
  args.outputs.primitives << labels.map do |l|
    as_label = l.label
    l.text.each_char.each_with_index.map do |char, i|
      [CENTER_OFFSET + EMULATED_FONT_X_ZERO + (as_label.x * TINY_SCALE) + i * 5 * TINY_SCALE,
       EMULATED_FONT_Y_ZERO + (as_label.y * TINY_SCALE), char,
       EMULATED_FONT_SIZE, 0, as_label.r, as_label.g, as_label.b, as_label.a, 'fonts/dragonruby-gtk-4x4.ttf'].label
    end
  end

  args.sprites    << [CENTER_OFFSET, 0, 1280 * TINY_SCALE, 720 * TINY_SCALE, :lowrez]
end

def render_gridlines_if_needed args
  if args.state.show_gridlines && args.static_lines.length == 0
    args.static_lines << 65.times.map do |i|
      [
        [CENTER_OFFSET + i * TINY_SCALE + 1,  0,
         CENTER_OFFSET + i * TINY_SCALE + 1,  720,                128, 128, 128],
        [CENTER_OFFSET + i * TINY_SCALE,      0,
         CENTER_OFFSET + i * TINY_SCALE,      720,                128, 128, 128],
        [CENTER_OFFSET,                       0 + i * TINY_SCALE,
         CENTER_OFFSET + 720,                 0 + i * TINY_SCALE, 128, 128, 128],
        [CENTER_OFFSET,                       1 + i * TINY_SCALE,
         CENTER_OFFSET + 720,                 1 + i * TINY_SCALE, 128, 128, 128]
      ]
    end
  elsif !args.state.show_gridlines
    args.static_lines.clear
  end
end
