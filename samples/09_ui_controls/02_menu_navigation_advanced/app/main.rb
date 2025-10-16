class Game
  attr_gtk

  def initialize
    # items to render within the menu
    @items = [
      { id: :bow, },
      { id: :boomerang, },
      { id: :hookshot, },
      { id: :bomb, },
      { id: :powder, },
      { id: :pot_1, },
      { id: :fire_rod, },
      { id: :ice_rod, },
      { id: :ether, },
      { id: :quake, },
      { id: :bombos, },
      { id: :pot_2, },
      { id: :lantern, },
      { id: :hammer, },
      { id: :flute, },
      { id: :net, },
      { id: :mudora, },
      { id: :pot_3, },
      { id: :shovel, },
      { id: :somaria, },
      { id: :bryna, },
      { id: :cape, },
      { id: :mirror, },
      { id: :pot3, },
      { id: :boots, },
      { id: :mitt, },
      { id: :flippers, },
      { id: :pearl, },
    ]

    # compute the menu location for each item and capture the rect
    # along with generating the prefab
    @items.each_with_index do |item, i|
      row = i.idiv(6)
      col = i % 6
      item.click_box = Layout.rect(row: 1 + row * 2, col: 0.50 + col * 2.5, w: 2, h: 2)
      item.prefab = [
        item.click_box.merge(path: :solid, r: 0, g: 0, b: 0),
        item.click_box.center.merge(text: "#{item.id}", r: 255, g: 255, b: 255, anchor_x: 0.5, anchor_y: 0.5)
      ]
    end
  end

  def tick
    calc
    render
  end

  def calc
    # set the hovered item to the first item
    @hovered_item ||= @items.first

    if inputs.last_active == :mouse
      # if the mouse is used, then recompute the hovered item
      # using the mouse location
      moused_item = @items.find { |item| Geometry.inside_rect? inputs.mouse, item.click_box }

      # if the mouse is over an item, then set it
      # as the new hovered item, otherwise keep the current selection
      @hovered_item = moused_item || @hovered_item

      # if mouse is clicked then select the item
      if inputs.mouse.click
        item_selected! @hovered_item
      end
    else
      # if controller or keyboard is the last active input
      # then use Geometry.rect_navigate to select the item
      @hovered_item = Geometry.rect_navigate(rect: @hovered_item,
                                             rects: @items,
                                             left_right: inputs.key_down.left_right,
                                             up_down: inputs.key_down.up_down,
                                             using: :click_box)

      # if enter (keyboard) or A (controller) is pressed, then select the item
      if inputs.keyboard.key_down.enter || inputs.controller_one.key_down.a
        item_selected! @hovered_item
      end
    end
  end

  # item selection logic would go here
  def item_selected! item
    GTK.notify "#{item.id} was selected."
  end

  def render
    outputs.background_color = [30, 30, 30]

    # Layout apis used to create the item menu
    # main items section
    outputs[:items_popup].primitives << Layout.rect(row: 0, col: 0, w: 15.5, h: 12)
                                              .merge(path: :solid, r: 255, g: 255, b: 255, a: 128)
    outputs[:items_popup].primitives << Layout.rect(row: 0, col: 0, w: 15, h: 1)
                                              .center
                                              .merge(text: "Items",
                                                     anchor_x: 0.5,
                                                     anchor_y: 0.5,
                                                     size_px: 48)

    outputs[:items_popup].primitives << @items.map(&:prefab)

    # example of using Layout to create other sections
    outputs[:items_popup].primitives << Layout.rect(row: 0, col: 15.5, w: 8.5, h: 3)
                                              .merge(path: :solid, r: 255, g: 255, b: 255, a: 128)
    outputs[:items_popup].primitives << Layout.rect(row: 0, col: 15.5, w: 8.5, h: 1)
                                              .center
                                              .merge(text: "Pendants",
                                                     anchor_x: 0.5,
                                                     anchor_y: 0.5,
                                                     size_px: 48)

    # example of using Layout to create other sections
    outputs[:items_popup].primitives << Layout.rect(row: 3, col: 15.5, w: 8.5, h: 3)
                                              .merge(path: :solid, r: 255, g: 255, b: 255, a: 128)
    outputs[:items_popup].primitives << Layout.rect(row: 3, col: 15.5, w: 8.5, h: 1)
                                              .center
                                              .merge(text: "Crystals",
                                                     anchor_x: 0.5,
                                                     anchor_y: 0.5,
                                                     size_px: 48)

    # example of using Layout to create other sections
    outputs[:items_popup].primitives << Layout.rect(row: 6, col: 15.5, w: 8.5, h: 6)
                                              .merge(path: :solid, r: 255, g: 255, b: 255, a: 128)
    outputs[:items_popup].primitives << Layout.rect(row: 6, col: 15.5, w: 8.5, h: 1)
                                              .center
                                              .merge(text: "Equipment",
                                                     anchor_x: 0.5,
                                                     anchor_y: 0.5,
                                                     size_px: 48)

    # render the current hovered item indicator and label
    outputs[:items_popup].primitives << @hovered_item.click_box.merge(path: :solid, r: 0, g: 160, b: 0, a: 128)
    outputs[:items_popup].primitives << Layout.rect(row: 11, col: 0, w: 15.5, h: 1)
                                              .center
                                              .merge(text: "Hovered Item: #{@hovered_item.id}", anchor_x: 0.5, anchor_y: 0.5)

    # fade and slide in animation
    perc = Easing.smooth_stop(start_at: 0,
                              duration: 90,
                              tick_count: Kernel.tick_count,
                              power: 3)

    outputs.primitives << { x: 0,
                            y: (1 - perc) * 1280,
                            w: 1280,
                            h: 720,
                            a: 255 * perc,
                            path: :items_popup }
  end
end

def boot args
  args.state = {}
end

def tick args
  $game ||= Game.new
  $game.args = args
  $game.tick
end

def reset args
  $game = nil
end

GTK.reset
