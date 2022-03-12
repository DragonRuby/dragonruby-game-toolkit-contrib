class Elements
  def initialize size
    @size = size
    @max_x_ordinal = 1280.idiv size
    @element_lookup = {}
    @elements = []
  end

  def add_element x_ordinal, y_ordinal
    return nil if @element_lookup.dig x_ordinal, y_ordinal
    element = Element.new x_ordinal, y_ordinal, @size
    @elements << element
    rehash_elements
    element
  end

  def tick
    fn.each_send @elements, self, :move_element
    rehash_elements
  end

  def move_element element
    if below_empty?(element) && element.y_ordinal != 0
      element.move  0, -1
    elsif below_left_empty?(element) && element.y_ordinal != 0 && element.x_ordinal != 0
      element.move -1, -1
    elsif below_right_empty?(element) && element.y_ordinal != 0 && element.x_ordinal != @max_x_ordinal
      element.move  1, -1
    end
  end

  def element_count
    @elements.length
  end

  def rehash_elements
    @element_lookup.clear
    fn.each_send @elements, self, :rehash_element
  end

  def rehash_element element
    @element_lookup[element.x_ordinal] ||= {}
    @element_lookup[element.x_ordinal][element.y_ordinal] = element
  end

  def below_empty? e
    return false if e.y_ordinal == 0
    return true  if !@element_lookup[e.x_ordinal]
    return true  if !@element_lookup[e.x_ordinal][e.y_ordinal - 1]
    return false if  @element_lookup[e.x_ordinal][e.y_ordinal - 1]
    return true
  end

  def below_left_empty? e
    return false if e.y_ordinal == 0
    return false if e.x_ordinal == 0
    return true  if !@element_lookup[e.x_ordinal - 1]
    return true  if !@element_lookup[e.x_ordinal - 1][e.y_ordinal - 1]
    return false if  @element_lookup[e.x_ordinal - 1][e.y_ordinal - 1]
    return true
  end

  def below_right_empty? e
    return false if e.y_ordinal == 0
    return false if e.x_ordinal == 256
    return true  if !@element_lookup[e.x_ordinal + 1]
    return true  if !@element_lookup[e.x_ordinal + 1][e.y_ordinal - 1]
    return false if  @element_lookup[e.x_ordinal + 1][e.y_ordinal - 1]
    return true
  end
end

class Element
  attr_sprite
  attr :x_ordinal, :y_ordinal

  def initialize x_ordinal, y_ordinal, s
    @x_ordinal     = x_ordinal
    @y_ordinal     = y_ordinal
    @s             = s
    @x             = x_ordinal * s
    @y             = y_ordinal * s
    @w             = s
    @h             = s
    @path          = "sprites/sand-element.png"
  end

  def draw_override ffi
    ffi.draw_sprite @x, @y, @w, @h, @path
  end

  def move dx, dy
    @y_ordinal += dy
    @x_ordinal += dx
    @y = @y_ordinal * @s
    @x = @x_ordinal * @s
  end
end

def tick args
  args.state.size        ||= 10
  args.state.mouse_state ||= :up
  @elements              ||= Elements.new args.state.size

  if args.inputs.mouse.down
    args.state.mouse_state = :held
  elsif args.inputs.mouse.up
    args.state.mouse_state = :released
  end

  if args.state.mouse_state == :held
    added = @elements.add_element args.inputs.mouse.x.idiv(args.state.size), args.inputs.mouse.y.idiv(args.state.size)
    args.outputs.static_sprites << added if added
  end

  @elements.tick

  args.outputs.labels << { x: 30, y: 30.from_top, text: "#{args.gtk.current_framerate.to_sf}" }
  args.outputs.labels << { x: 30, y: 60.from_top, text: "#{@elements.element_count}" }
end

$gtk.reset
@elements = nil
