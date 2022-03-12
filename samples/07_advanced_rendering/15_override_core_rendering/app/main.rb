class GTK::Runtime
  # You can completely override how DR renders by defining this method
  # It is strongly recommend that you do not do this unless you know what you're doing.
  def primitives pass
    # fn.each_send pass.solids,            self, :draw_solid
    # fn.each_send pass.static_solids,     self, :draw_solid
    # fn.each_send pass.sprites,           self, :draw_sprite
    # fn.each_send pass.static_sprites,    self, :draw_sprite
    # fn.each_send pass.primitives,        self, :draw_primitive
    # fn.each_send pass.static_primitives, self, :draw_primitive
    fn.each_send pass.labels,            self, :draw_label
    fn.each_send pass.static_labels,     self, :draw_label
    # fn.each_send pass.lines,             self, :draw_line
    # fn.each_send pass.static_lines,      self, :draw_line
    # fn.each_send pass.borders,           self, :draw_border
    # fn.each_send pass.static_borders,    self, :draw_border

    # if !self.production
    #   fn.each_send pass.debug,           self, :draw_primitive
    #   fn.each_send pass.static_debug,    self, :draw_primitive
    # end

    # fn.each_send pass.reserved,          self, :draw_primitive
    # fn.each_send pass.static_reserved,   self, :draw_primitive
  end
end

def tick args
  args.outputs.labels << { x: 30, y: 30, text: "primitives function defined, only labels rendered" }
  args.outputs.sprites << { x: 100, y: 100, w: 100, h: 100, path: "dragonruby.png" }
end
