# A collection of function related to elements of natrue
class Element
  # returns the tile size in pixels { w:, h: }
  # Layout::rect is a virtual grid that is 24 columns by 12 rows
  def self.tile_size
    Layout::rect(w: 1, h: 1)
           .slice(:w, :h)
  end

  # given a point/position in pixels, returns a rect with
  # { x:, y:, w:, h:, center: { x:, y: } }
  def self.tile_rect x:, y:, anchor_x: 0, anchor_y: 0, **ignore
    w, h = tile_size.values_at(:w, :h)
    Geometry.rect_props x: x - w * anchor_x,
                        y: y - h * anchor_y,
                        w: w,
                        h: h
  end

  # given a element, and it's position, this fucntion
  # returns render primitives that represent the element
  # visually
  def self.prefab_icon element, x:, y:, anchor_x: 0, anchor_y: 0, **ignore
    # if the element is decorated with an added_at property,
    # it means that we want to apply a fade in effect to the
    # prefab
    a = if element.added_at && element.added_at.elapsed_time < 60
          # fade in slow to fast over 1 second
          perc = Easing.ease element.added_at, Kernel.tick_count, 60, :smooth_start_quint
          255 * perc
        else
          255
        end

    # given the elements position, create a tile rect with the sprite and alpha
    tile_rect(x: x, y: y).merge(path: "sprites/square/#{element.name}.png", a: a)
  end

  # this represents the element prefab it its entirety
  # the sprite, a background rect and a text label above the
  # background rect
  def self.prefab element, position, shift_x: 0, shift_y: 0
    rect = tile_rect x: position.x + shift_x,
                     y: position.y + shift_y

    [
      # icon
      prefab_icon(element, x: position.x, y: position.y),
      # background rect
      rect.merge(path: :solid, h: 16, r: 0, g: 0, b: 0, a: 200),
      # text label
      {
        x: rect.center.x,
        y: rect.y,
        text: "#{element.name}",
        anchor_x: 0.5,
        anchor_y: 0,
        size_px: 16,
        r: 255,
        g: 255,
        b: 255
      },

      # white border
      rect.merge(primitive_marker: :border, r: 255, g: 255, b: 255)
    ]
  end

  # given a collection of elements,
  # this function returns a collection of grouped elements
  # (elements that are intersecting each other, or connected
  # to each other, because of a mutual neighbor element)
  def self.create_groupings elements
    grouped_elements = []

    rects_with_source = elements.map do |r|
      r.rect.merge(source: r)
    end

    rects_with_source.each do |r|
      grouped = grouped_elements.find do |g|
        g.any? { |i| i.intersect_rect? r }
      end

      if !grouped
        grouped_elements << [r]
      else
        grouped << r
      end
    end

    grouped_elements.map do |e|
      e.map { |r| r.source }
    end.uniq
  end
end

class Game
  attr_gtk

  def tick
    defaults
    calc
    render
  end

  def defaults
    # elements of nature and what they require to be created
    state.elements ||= [
      { name: :violet,  requires: [:red, :blue, :black] },
      { name: :indigo,  requires: [:red, :blue, :white] },
      { name: :gray,    requires: [:white, :black] },
      { name: :green,   requires: [:blue, :yellow] },
      { name: :orange,  requires: [:red, :yellow] },
    ]

    # elements that have been discovered seeded with the basic elements
    state.discovered_elements ||= [
      { name: :white },
      { name: :black },
      { name: :red },
      { name: :yellow },
      { name: :blue },
    ]

    # the canvas area where elements are placed/mixed
    state.canvas ||= {
      rect: Layout::rect(row: 0, col: 0, w: 20, h: 12),
      elements: []
    }

    # fx queue for faiding out sprites
    state.fade_out_queue ||= []

    # fx queue for mouse particles
    state.mouse_particles_queue ||= []

    # invalid mixtures queue (used to signal invalid mixtures)
    state.invalid_mixtures_queue ||= []
  end

  # adds a clone of an element to the canvas area
  # used by mouse movement and click events
  # and element discovery
  def add_element_to_canvas! element, position, fade_in: false
    return if !element
    new_entry = element.copy
    new_entry.added_at = Kernel.tick_count if fade_in
    new_entry.position = { x: position.x, y: position.y }
    state.canvas.elements << new_entry
    new_entry
  end

  def input_mouse
    # if the mouse is clicked...
    if inputs.mouse.down
      # check to see if any of the elements in the toolbar
      # were clicked, if so, set the selected element to the
      # clicked element
      toolbar_element = state.discovered_elements
                             .find do |r|
                               inputs.mouse.intersect_rect? r.rect
                             end

      if toolbar_element
        state.selected_element = toolbar_element
      end

      # if no toolbar element was clicked, then check to see
      # if an element on the canvas was clicked
      if !state.selected_element
        state.selected_element = state.canvas.elements.reverse.find do |r|
          inputs.mouse.intersect_rect? r.rect
        end

        # if an element was clicked, remove it from the canvas
        if state.selected_element
          state.canvas.elements.reject! { |r| r == state.selected_element }
        end
      end

      if state.selected_element
        state.selected_element = state.selected_element.copy
      end
    elsif inputs.mouse.held && inputs.mouse.moved
      # emit pretty particles when the mouse is held and moved
      if Kernel.tick_count.zmod? 2
        state.mouse_particles_queue << {
          x: inputs.mouse.x + 10.randomize(:ratio, :sign),
          y: inputs.mouse.y + 10.randomize(:ratio, :sign),
          w: 10, h: 10, path: "sprites/star.png"
        }
      end
    elsif inputs.mouse.up
      if state.selected_element
        # if mouse is released,
        # cr
        if inputs.mouse.intersect_rect?(state.canvas.rect)
          rect = Element.tile_rect(x: inputs.mouse.up.x,
                                   y: inputs.mouse.up.y,
                                   anchor_x: 0.5,
                                   anchor_y: 0.5)


          # add the element to the canvas area and create particles
          # around the element drop
          created_element = add_element_to_canvas! state.selected_element, rect

          # get all intersecting elements with the element that was just being dragged
          intersecting_elements = state.canvas.elements.find_all do |element|
            element != created_element && Geometry::intersect_rect?(element.rect, created_element.rect)
          end

          # shake elements if the element doesn't have any potential interactions
          notify_invalid_mixture! created_element, intersecting_elements

          state.mouse_particles_queue.concat(30.map do |i|
                                               { x: rect.center.x + 10.randomize(:ratio, :sign),
                                                 y: rect.center.y + 10.randomize(:ratio, :sign),
                                                 start_at: Kernel.tick_count + i + rand(2),
                                                 w: 10, h: 10, path: "sprites/star.png" }
                                             end)

        else
          # if the mouse was released outside of the canvas area
          # then delete the element/remove it from the canvas
          w, h = Element.tile_size.values_at(:w, :h)

          # add the element to the fade out queue
          state.fade_out_queue << Element.prefab_icon(state.selected_element,
                                                      x: inputs.mouse.up.x - w / 2,
                                                      y: inputs.mouse.up.y - h / 2,
                                                      anchor_x: 0.5,
                                                      anchor_y: 0.5)
        end
      end

      state.selected_element = nil
    end
  end

  def notify_invalid_mixture! source, intersecting_elements
    return if intersecting_elements.length == 0

    # look through all the intersecting elements
    # see if any of their requirements match the source element
    # or the intersecting element
    possible = intersecting_elements.any? do |r|
      state.elements.any? do |sr|
        sr.requires.include?(source.name) &&
        sr.requires.include?(r.name)
      end
    end

    # check to see if the source element and the intersecting element
    # are of the same type
    duplicate_ids = intersecting_elements.any? { |r| r.name == source.name }

    # play an error sound if the requirements for interactions don't match,
    # or if duplicate elements are touching
    if !possible || duplicate_ids
      state.invalid_mixtures_queue << { ref_id: source.object_id, at: Kernel.tick_count }
      intersecting_elements.each do |r|
        state.invalid_mixtures_queue << { ref_id: r.object_id, at: Kernel.tick_count }
      end
    end
  end

  def calc
    calc_collision_bodies
    input_mouse
    calc_discovered_elements
    calc_queues
    calc_collision_bodies
  end

  def calc_queues
    # process the fade out queue
    state.fade_out_queue.each do |fx|
      fx.dx ||= 0.1
      fx.dy ||= 0.1
      fx.a ||= 255
      fx.a -= 5
      fx.x += fx.dx
      fx.y += fx.dy
      fx.w -= fx.dx * 2 if fx.w > 0
      fx.h -= fx.dy * 2 if fx.h > 0
      fx.dx *= 1.1
      fx.dy *= 1.1
    end

    state.fade_out_queue.reject! { |fx| fx.a <= 0 }

    # process the mouse particles queue
    state.mouse_particles_queue.each do |mp|
      mp.start_at ||= Kernel.tick_count
      mp.a ||= 255
      if mp.start_at < Kernel.tick_count
        mp.dx ||= 1.randomize(:ratio, :sign)
        mp.dy ||= 1.randomize(:ratio, :sign)
        mp.x += mp.dx
        mp.y += mp.dy
        mp.a -= 5
        mp.dx *= 1.05
        mp.dy *= 1.05
      end
    end

    state.mouse_particles_queue.reject! { |mp| mp.a <= 0 }

    state.invalid_mixtures_queue.reject! do |fx|
      fx.at.elapsed_time > 15
    end
  end

  def calc_discovered_elements
    groups = Element.create_groupings state.canvas.elements

    while groups.length > 0
      # pop a group of elements from the groups array
      group = groups.pop

      # for all the elements, get their names, this
      # represets the collection of elements that are
      # needed for other elements to be created (based on their requirements)
      keys = group.map { |g| g.name }
      completed_element = nil

      # for all elements, check their requires, and see if
      # the group of elements that are touching match
      state.elements.each do |r|
        if r.requires.uniq - keys == []
          completed_element = r
          break
        end
      end

      # if an element can be created, then remove the elements
      # that were used to create the element
      if completed_element
        to_remove = []
        completed_element.requires.each do |r|
          group.each do |g|
            if r == g.name
              to_remove << g
              break
            end
          end
        end

        # compute the general center of the cluster of elements
        min_x = to_remove.map { |i| i.position.x }.min
        min_y = to_remove.map { |i| i.position.y }.min
        max_x = to_remove.map { |i| i.position.x }.max
        max_y = to_remove.map { |i| i.position.y }.max
        avg_x = (min_x + max_x) / 2
        avg_y = (min_y + max_y) / 2

        # remove each used element from the canvas
        # fade them out, and add the new element to the canvas
        to_remove.each do |r|
          state.canvas.elements.reject! { |i| i == r }
          state.fade_out_queue << Element.prefab_icon(r, r.position)

          add_element_to_canvas!(completed_element,
                                 Element.tile_rect(x: avg_x, y: avg_y),
                                 fade_in: true)
        end

        # if the newly created element is not in the list of discovered elements
        # then add it to the list of discovered elements
        if state.discovered_elements.none? { |i| i.name == completed_element.name }
          state.discovered_elements << { name: completed_element.name, added_at: Kernel.tick_count }
        end
      end
    end
  end

  def calc_collision_bodies
    state.discovered_elements.each_with_index do |e, i|
      r = Layout::rect(row: i, col: 20, w: 1, h: 1)
      e.merge! rect: Layout::rect(row: i, col: 20, w: 1, h: 1),
               position: r.slice(:x, :y)
    end

    state.canvas.elements.each do |e|
      r = Element.tile_rect(e.position)
      e.merge! rect: r,
               position: r.slice(:x, :y)
    end

    if state.selected_element
      r = Element.tile_rect(x: inputs.mouse.position.x, y: inputs.mouse.position.y, anchor_x: 0.5, anchor_y: 0.5)
      state.selected_element.merge!(rect: r, position: r.slice(:x, :y))
    end
  end

  def render
    render_bg
    render_toolbar
    render_canvas_elements
    render_selected_element
    render_queues
  end

  def render_queues
    outputs.primitives << state.fade_out_queue
    outputs.primitives << state.mouse_particles_queue.reject { |mp| mp.start_at > Kernel.tick_count }
  end

  def render_selected_element
    # if an element is selected, render it at the mouse position
    if state.selected_element
      w, h = Layout::rect(w: 1, h: 1).values_at(:w, :h)
      outputs.primitives << Element.prefab(state.selected_element,
                                           x: inputs.mouse.x - w / 2,
                                           y: inputs.mouse.y - h / 2)
    end
  end

  def render_bg
    # black letterbox
    outputs.background_color = [0, 0, 0]

    # canvas area with lighter purple
    outputs.primitives << Layout::rect(row: 0, col:  0, w: 20, h: 12).merge(path: :solid, r: 59, g: 58, b: 97)

    # toolbar area with darker purple
    outputs.primitives << Layout::rect(row: 0, col: 20, w: 4, h: 12).merge(path: :solid, r: 59, g: 58, b: 80)

    # border around the canvas area
    outputs.primitives << state.canvas.rect.merge(primitive_marker: :border, r: 255, g: 255, b: 255)
  end

  def render_toolbar
    unique_elements = (state.elements.map { |r| r.name } +
                       state.discovered_elements.map { |r| r.name }).uniq
    outputs.primitives << unique_elements.length.map.with_index do |r, i|
      if i <= state.discovered_elements.length - 1
        nil
      else
        # for all undiscovered elements, create a placeholder question mark box
        Layout::rect(row: i, col: 20)
               .yield_self do |r|
                 [
                   r.merge(primitive_marker: :border, r: 255, g: 255, b: 255),
                   r.center.merge(text: "?", anchor_x: 0.5, anchor_y: 0.5, r: 255, g: 255, b: 255)
                 ]
               end
      end
    end

    # create a prefab for each discovered element
    outputs.primitives << state.discovered_elements.map.with_index do |r, i|
      hover = if inputs.mouse.intersect_rect? r.rect
                r.rect.merge(path: :solid, r: 0, g: 80, b: 80, a: 100)
              end

      [Element.prefab(r, r.position), hover]
    end
  end

  def render_canvas_elements
    if inputs.mouse.held && state.selected_element
      grouped_elements = Element.create_groupings(state.canvas.elements)

      # get all elements that are connected to the selected element
      # (ie intersecting with the mouse)
      connected_to_mouse = grouped_elements.find_all do |g|
        g.find { |e| Geometry::intersect_rect? state.selected_element.rect, e.rect }
      end.flatten

      outputs.primitives << state.canvas.elements.map do |element|
        is_part_of_invalid_mixture = state.invalid_mixtures_queue.any? { |i| i.ref_id == element.object_id }

        shift_x, shift_y = if is_part_of_invalid_mixture
                             [5.randomize(:ratio, :sign), 5.randomize(:ratio, :sign)]
                           else
                             [0, 0]
                           end

        pre = Element.prefab element, element.position, shift_x: shift_x, shift_y: shift_y
        # if the element that is about to be rendered is connected to the selected element
        # then render it with a hover effect
        hover = if state.selected_element && connected_to_mouse.any? { |i| i == element }
                  element.rect.merge(path: :solid, r: 0, g: 80, b: 80, a: 100)
                end
        [pre, hover]
      end
    else
      # hover effect for mouse intersecting topmost element
      mouse_intersecting_element = if !inputs.mouse.held
                                     state.canvas.elements.reverse.find do |element|
                                       Geometry::intersect_rect? inputs.mouse, element.rect
                                     end
                                   end

      outputs.primitives << state.canvas.elements.map do |element|
        is_part_of_invalid_mixture = state.invalid_mixtures_queue.any? { |i| i.ref_id == element.object_id }

        shift_x, shift_y = if is_part_of_invalid_mixture
                             [5.randomize(:ratio, :sign), 5.randomize(:ratio, :sign)]
                           else
                             [0, 0]
                           end

        pre = Element.prefab element, element.position, shift_x: shift_x, shift_y: shift_y
        hover = if mouse_intersecting_element == element
                  element.rect.merge(path: :solid, r: 0, g: 80, b: 80, a: 100)
                end
        [pre, hover]
      end
    end
  end
end

$game = Game.new
def tick args
  $game.args = args
  $game.tick
end
