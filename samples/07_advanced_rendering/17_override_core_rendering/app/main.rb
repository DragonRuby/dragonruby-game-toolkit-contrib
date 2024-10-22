class GTK::Runtime
  # You can completely override how DR renders by defining this method
  # It is strongly recommend that you do not do this unless you know what you're doing.
  def primitives pass
    # pass.solids.each { |o| draw_solid o }
    # pass.static_solids.each { |o| draw_solid o }
    # pass.sprites.each { |o| draw_sprite o }
    # pass.static_sprites.each { |o| draw_sprite o }
    # pass.primitives.each { |o| draw_primitive o }
    # pass.static_primitives.each { |o| draw_primitive o }
    pass.labels.each { |o| draw_label o }
    pass.static_labels.each { |o| draw_label o }
    # pass.lines.each { |o| draw_line o }
    # pass.static_lines.each { |o| draw_line o }
    # pass.borders.each { |o| draw_border o }
    # pass.static_borders.each { |o| draw_border o }

    # if !self.production
    #   pass.debug.each { |o| draw_primitive o }
    #   pass.static_debug.each { |o| draw_primitive o }
    # end

    # pass.reserved.each { |o| draw_primitive o }
    # pass.static_reserved.each { |o| draw_primitive o }
  end
end

def tick args
  args.outputs.labels << { x: 30, y: 30, text: "primitives function defined, only labels rendered" }
  args.outputs.sprites << { x: 100, y: 100, w: 100, h: 100, path: "dragonruby.png" }
end
