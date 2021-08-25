# ==================================================
# A NOTE TO JAM CRAFT PARTICIPANTS:
# The comments and code in here are just as small piece of DragonRuby's capabilities.
# Be sure to check out the rest of the sample apps. Start with README.txt and go from there!
# ==================================================

# def tick args is the entry point into your game. This function is called at
# a fixed update time of 60hz (60 fps).
def tick args
  # The defaults function intitializes the game.
  defaults args

  # After the game is initialized, render it.
  render args

  # After rendering the player should be able to respond to input.
  input args

  # After responding to input, the game performs any additional calculations.
  calc args
end

def defaults args
  # hide the mouse cursor for this game, we are going to render our own cursor
  if args.state.tick_count == 0
    args.gtk.hide_cursor
  end

  args.state.click_ripples ||= []

  # everything is on a 1280x720 virtual canvas, so you can
  # hardcode locations

  # define the borders for where the inventory is located
  # args.state is a data structure that accepts any arbitrary parameters
  # so you can create an object graph without having to create any classes.

  # Bottom left is 0, 0. Top right is 1280, 720.
  # The inventory area is at the top of the screen
  # the number 80 is the size of all the sprites, so that is what is being
  # used to decide the with and height
  args.state.sprite_size = 80

  args.state.inventory_border.w  = args.state.sprite_size * 10
  args.state.inventory_border.h  = args.state.sprite_size * 3
  args.state.inventory_border.x  = 10
  args.state.inventory_border.y  = 710 - args.state.inventory_border.h

  # define the borders for where the crafting area is located
  # the crafting area is below the inventory area
  # the number 80 is the size of all the sprites, so that is what is being
  # used to decide the with and height
  args.state.craft_border.x =  10
  args.state.craft_border.y = 220
  args.state.craft_border.w = args.state.sprite_size * 3
  args.state.craft_border.h = args.state.sprite_size * 3

  # define the area where results are located
  # the crafting result is to the right of the craft area
  args.state.result_border.x =  10 + args.state.sprite_size * 3 + args.state.sprite_size
  args.state.result_border.y = 220 + args.state.sprite_size
  args.state.result_border.w = args.state.sprite_size
  args.state.result_border.h = args.state.sprite_size

  # initialize items for the first time if they are nil
  # you start with 15 wood, 1 chest, and 5 plank
  # Ruby has built in syntax for dictionaries (they look a lot like json objects).
  # Ruby also has a special type called a Symbol denoted with a : followed by a word.
  # Symbols are nice because they remove the need for magic strings.
  if !args.state.items
    args.state.items = [
      {
        id: :wood, # :wood is a Symbol, this is better than using "wood" for the id
        quantity: 15,
        path: 'sprites/wood.png',
        location: :inventory,
        ordinal_x: 0, ordinal_y: 0
      },
      {
        id: :chest,
        quantity: 1,
        path: 'sprites/chest.png',
        location: :inventory,
        ordinal_x: 1, ordinal_y: 0
      },
      {
        id: :plank,
        quantity: 5,
        path: 'sprites/plank.png',
        location: :inventory,
        ordinal_x: 2, ordinal_y: 0
      },
    ]

    # after initializing the oridinal positions, derive the pixel
    # locations assuming that the width and height are 80
    args.state.items.each { |item| set_inventory_position args, item }
  end

  # define all the oridinal positions of the inventory slots
  if !args.state.inventory_area
    args.state.inventory_area = [
      { ordinal_x: 0,  ordinal_y: 0 },
      { ordinal_x: 1,  ordinal_y: 0 },
      { ordinal_x: 2,  ordinal_y: 0 },
      { ordinal_x: 3,  ordinal_y: 0 },
      { ordinal_x: 4,  ordinal_y: 0 },
      { ordinal_x: 5,  ordinal_y: 0 },
      { ordinal_x: 6,  ordinal_y: 0 },
      { ordinal_x: 7,  ordinal_y: 0 },
      { ordinal_x: 8,  ordinal_y: 0 },
      { ordinal_x: 9,  ordinal_y: 0 },
      { ordinal_x: 0,  ordinal_y: 1 },
      { ordinal_x: 1,  ordinal_y: 1 },
      { ordinal_x: 2,  ordinal_y: 1 },
      { ordinal_x: 3,  ordinal_y: 1 },
      { ordinal_x: 4,  ordinal_y: 1 },
      { ordinal_x: 5,  ordinal_y: 1 },
      { ordinal_x: 6,  ordinal_y: 1 },
      { ordinal_x: 7,  ordinal_y: 1 },
      { ordinal_x: 8,  ordinal_y: 1 },
      { ordinal_x: 9,  ordinal_y: 1 },
      { ordinal_x: 0,  ordinal_y: 2 },
      { ordinal_x: 1,  ordinal_y: 2 },
      { ordinal_x: 2,  ordinal_y: 2 },
      { ordinal_x: 3,  ordinal_y: 2 },
      { ordinal_x: 4,  ordinal_y: 2 },
      { ordinal_x: 5,  ordinal_y: 2 },
      { ordinal_x: 6,  ordinal_y: 2 },
      { ordinal_x: 7,  ordinal_y: 2 },
      { ordinal_x: 8,  ordinal_y: 2 },
      { ordinal_x: 9,  ordinal_y: 2 },
    ]

    # after initializing the oridinal positions, derive the pixel
    # locations assuming that the width and height are 80
    args.state.inventory_area.each { |i| set_inventory_position args, i }

    # if you want to see the result you can use the Ruby function called "puts".
    # Uncomment this line to see the value.
    # puts args.state.inventory_area

    # You can see all things written via puts in DragonRuby's Console, or under logs/log.txt.
    # To bring up DragonRuby's Console, press the ~ key within the game.
  end

  # define all the oridinal positions of the craft slots
  if !args.state.craft_area
    args.state.craft_area = [
      { ordinal_x: 0, ordinal_y: 0 },
      { ordinal_x: 0, ordinal_y: 1 },
      { ordinal_x: 0, ordinal_y: 2 },
      { ordinal_x: 1, ordinal_y: 0 },
      { ordinal_x: 1, ordinal_y: 1 },
      { ordinal_x: 1, ordinal_y: 2 },
      { ordinal_x: 2, ordinal_y: 0 },
      { ordinal_x: 2, ordinal_y: 1 },
      { ordinal_x: 2, ordinal_y: 2 },
    ]

    # after initializing the oridinal positions, derive the pixel
    # locations assuming that the width and height are 80
    args.state.craft_area.each { |c| set_craft_position args, c }
  end
end


def render args
  # for the results area, create a sprite that show its boundaries
  args.outputs.primitives << { x: args.state.result_border.x,
                               y: args.state.result_border.y,
                               w: args.state.result_border.w,
                               h: args.state.result_border.h,
                               path: 'sprites/border-black.png' }

  # for each inventory spot, create a sprite
  # args.outputs.primitives is how DragonRuby performs a render.
  # Adding a single hash or multiple hashes to this array will tell
  # DragonRuby to render those primitives on that frame.

  # The .map function on Array is used instead of any kind of looping.
  # .map returns a new object for every object within an Array.
  args.outputs.primitives << args.state.inventory_area.map do |a|
    { x: a.x, y: a.y, w: a.w, h: a.h, path: 'sprites/border-black.png' }
  end

  # for each craft spot, create a sprite
  args.outputs.primitives << args.state.craft_area.map do |a|
    { x: a.x, y: a.y, w: a.w, h: a.h, path: 'sprites/border-black.png' }
  end

  # after the borders have been rendered, render the
  # items within those slots (and allow for highlighting)
  # if an item isn't currently being held
  allow_inventory_highlighting = !args.state.held_item

  # go through each item and render them
  # use Array's find_all method to remove any items that are currently being held
  args.state.items.find_all { |item| item[:location] != :held }.map do |item|
    # if an item is currently being held, don't render it in it's spot within the
    # inventory or craft area (this is handled via the find_all method).

    # the item_prefab returns a hash containing all the visual components of an item.
    # the main sprite, the black background, the quantity text, and a hover indication
    # if the mouse is currently hovering over the item.
    args.outputs.primitives << item_prefab(args, item, allow_inventory_highlighting, args.inputs.mouse)
  end

  # The last thing we want to render is the item currently being held.
  args.outputs.primitives << item_prefab(args, args.state.held_item, allow_inventory_highlighting, args.inputs.mouse)

  args.outputs.primitives << args.state.click_ripples

  # render a mouse cursor since we have the OS cursor hidden
  args.outputs.primitives << { x: args.inputs.mouse.x - 5, y: args.inputs.mouse.y - 5, w: 10, h: 10, path: 'sprites/circle-gray.png', a: 128 }
end

# Alrighty! This is where all the fun happens
def input args
  # if the mouse is clicked and not item is currently being held
  # args.state.held_item is nil when the game starts.
  # If the player clicks, the property args.inputs.mouse.click will
  # be a non nil value, we don't want to process any of the code here
  # if the mouse hasn't been clicked
  return if !args.inputs.mouse.click

  # if a click occurred, add a ripple to the ripple queue
  args.state.click_ripples << { x: args.inputs.mouse.x - 5, y: args.inputs.mouse.y - 5, w: 10, h: 10, path: 'sprites/circle-gray.png', a: 128 }

  # if the mouse has been clicked, and no item is currently held...
  if !args.state.held_item
    # see if any of the items intersect the pointer using the inside_rect? method
    # the find method will either return the first object that returns true
    # for the match clause, or it'll return nil if nothing matches the match clause
    found = args.state.items.find do |item|
      # for each item in args.state.items, run the following boolean check
      args.inputs.mouse.click.point.inside_rect?(item)
    end

    # if an item intersects the mouse pointer, then set the item's location to :held and
    # set args.state.held_item to the item for later reference
    if found
      args.state.held_item = found
      found[:location] = :held
    end

  # if the mouse is clicked and an item is currently beign held....
  elsif args.state.held_item
    # determine if a slot within the craft area was clicked
    craft_area = args.state.craft_area.find { |a| args.inputs.mouse.click.point.inside_rect? a }

    # also determine if a slot within the inventory area was clicked
    inventory_area = args.state.inventory_area.find { |a| args.inputs.mouse.click.point.inside_rect? a }

    # if the click was within a craft area
    if craft_area
      # check to see if an item is already there and ignore the click if an item is found
      # item_at_craft_slot is a helper method that returns an item or nil for a given oridinal
      # position
      item_already_there = item_at_craft_slot args, craft_area[:ordinal_x], craft_area[:ordinal_y]

      # if an item *doesn't* exist in the craft area
      if !item_already_there
        # if the quantity they are currently holding is greater than 1
        if args.state.held_item[:quantity] > 1
          # remove one item (creating a seperate item of the same type), and place it
          # at the oridinal position and location of the craft area
          # the .merge method on Hash creates a new Hash, but updates any values
          # passed as arguments to merge
          new_item = args.state.held_item.merge(quantity: 1,
                                                location: :craft,
                                                ordinal_x: craft_area[:ordinal_x],
                                                ordinal_y: craft_area[:ordinal_y])

          # after the item is crated, place it into the args.state.items collection
          args.state.items << new_item

          # then subtract one from the held item
          args.state.held_item[:quantity] -= 1

        # if the craft area is available and there is only one item being held
        elsif args.state.held_item[:quantity] == 1
          # instead of creating any new items just set the location of the held item
          # to the oridinal position of the craft area, and then nil out the
          # held item state so that a new item can be picked up
          args.state.held_item[:location] = :craft
          args.state.held_item[:ordinal_x] = craft_area[:ordinal_x]
          args.state.held_item[:ordinal_y] = craft_area[:ordinal_y]
          args.state.held_item = nil
        end
      end

    # if the selected area is an inventory area (as opposed to within the craft area)
    elsif inventory_area

      # check to see if there is already an item in that inventory slot
      # the item_at_inventory_slot helper method returns an item or nil
      item_already_there = item_at_inventory_slot args, inventory_area[:ordinal_x], inventory_area[:ordinal_y]

      # if there is already an item there, and the item types/id match
      if item_already_there && item_already_there[:id] == args.state.held_item[:id]
        # then merge the item quantities
        held_quantity = args.state.held_item[:quantity]
        item_already_there[:quantity] += held_quantity

        # remove the item being held from the items collection (since it's quantity is now 0)
        args.state.items.reject! { |i| i[:location] == :held }

        # nil out the held_item so a new item can be picked up
        args.state.held_item = nil

      # if there currently isn't an item there, then put the held item in the slot
      elsif !item_already_there
        args.state.held_item[:location] = :inventory
        args.state.held_item[:ordinal_x] = inventory_area[:ordinal_x]
        args.state.held_item[:ordinal_y] = inventory_area[:ordinal_y]

        # nil out the held_item so a new item can be picked up
        args.state.held_item = nil
      end
    end
  end
end

# the calc method is executed after input
def calc args
  # make sure that the real position of the inventory
  # items are updated every frame to ensure that they
  # are placed correctly given their location and oridinal positions
  # instead of using .map, here we use .each (since we are not returning a new item and just updating the items in place)
  args.state.items.each do |item|
    # based on the location of the item, invoke the correct pixel conversion method
    if item[:location] == :inventory
      set_inventory_position args, item
    elsif item[:location] == :craft
      set_craft_position args, item
    elsif item[:location] == :held
      # if the item is held, center the item around the mouse pointer
      args.state.held_item.x = args.inputs.mouse.x - args.state.held_item.w.half
      args.state.held_item.y = args.inputs.mouse.y - args.state.held_item.h.half
    end
  end

  # for each hash/sprite in the click ripples queue,
  # expand its size by 20 percent and decrease its alpha
  # by 10.
  args.state.click_ripples.each do |ripple|
    delta_w = ripple.w * 1.2 - ripple.w
    delta_h = ripple.h * 1.2 - ripple.h
    ripple.x -= delta_w.half
    ripple.y -= delta_h.half
    ripple.w += delta_w
    ripple.h += delta_h
    ripple.a -= 10
  end

  # remove any items from the collection where the alpha value is less than equal to
  # zero using the reject! method (reject with an exclamation point at the end changes the
  # array value in place, while reject without the exclamation point returns a new array).
  args.state.click_ripples.reject! { |ripple| ripple.a <= 0 }
end

# helper function for finding an item at a craft slot
def item_at_craft_slot args, ordinal_x, ordinal_y
  args.state.items.find { |i| i[:location] == :craft && i[:ordinal_x] == ordinal_x && i[:ordinal_y] == ordinal_y }
end

# helper function for finding an item at an inventory slot
def item_at_inventory_slot args, ordinal_x, ordinal_y
  args.state.items.find { |i| i[:location] == :inventory && i[:ordinal_x] == ordinal_x && i[:ordinal_y] == ordinal_y }
end

# helper function that creates a visual representation of an item
def item_prefab args, item, should_highlight, mouse
  return nil unless item

  overlay = nil

  x = item.x
  y = item.y
  w = item.w
  h = item.h

  if should_highlight && mouse.point.inside_rect?(item)
    overlay = { x: x, y: y, w: w, h: h, path: "sprites/square-blue.png", a: 130, }
  end

  [
    # sprites are hashes with a path property, this is the main sprite
    { x: x,      y: y, w: args.state.sprite_size, h: args.state.sprite_size, path: item[:path], },

    # this represents the black area in the bottom right corner of the main sprite so that the
    # quantity is visible
    { x: x + 55, y: y, w: 25, h: 25, path: "sprites/square-black.png", }, # sprites are hashes with a path property

    # labels are hashes with a text property
    { x: x + 56, y: y + 22, text: "#{item[:quantity]}", r: 255, g: 255, b: 255, },

    # this is the mouse overlay, if the overlay isn't applicable, then this value will be nil (nil values will not be rendered)
    overlay
  ]
end

# helper function for deriving the position of an item within inventory
def set_inventory_position args, item
  item.x = args.state.inventory_border.x + item[:ordinal_x] * 80
  item.y = (args.state.inventory_border.y + args.state.inventory_border.h - 80) - item[:ordinal_y] * 80
  item.w = 80
  item.h = 80
end

# helper function for deriving the position of an item within the craft area
def set_craft_position args, item
  item.x = args.state.craft_border.x + item[:ordinal_x] * 80
  item.y = (args.state.craft_border.y + args.state.inventory_border.h - 80) - item[:ordinal_y] * 80
  item.w = 80
  item.h = 80
end

# Any lines outside of a function will be executed when the file is reloaded.
# So every time you save main.rb, the game will be reset.
# Comment out the line below if you don't want this to happen.
$gtk.reset
