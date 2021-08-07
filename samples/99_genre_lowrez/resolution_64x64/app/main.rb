require 'app/lowrez.rb'

def tick args
  # How to set the background color
  args.lowrez.background_color = [255, 255, 255]

  # ==== HELLO WORLD ======================================================
  # Steps to get started:
  # 1. ~def tick args~ is the entry point for your game.
  # 2. There are quite a few code samples below, remove the "##"
  #    before each line and save the file to see the changes.
  # 3. 0,  0 is in bottom left and 63, 63 is in top right corner.
  # 4. Be sure to come to the discord channel if you need
  #    more help: [[http://discord.dragonruby.org]].

  # Commenting and uncommenting code:
  # - Add a "#" infront of lines to comment out code
  # - Remove the "#" infront of lines to comment out code

  # Invoke the hello_world subroutine/method
  hello_world args # <---- add a "#" to the beginning of the line to stop running this subroutine/method.
  # =======================================================================


  # ==== HOW TO RENDER A LABEL ============================================
  # Uncomment the line below to invoke the how_to_render_a_label subroutine/method.
  # Note: The method is defined in this file with the signature ~def how_to_render_a_label args~
  #       Scroll down to the method to see the details.

  # Remove the "#" at the beginning of the line below
  # how_to_render_a_label args # <---- remove the "#" at the begging of this line to run the method
  # =======================================================================


  # ==== HOW TO RENDER A FILLED SQUARE (SOLID) ============================
  # Remove the "#" at the beginning of the line below
  # how_to_render_solids args
  # =======================================================================


  # ==== HOW TO RENDER AN UNFILLED SQUARE (BORDER) ========================
  # Remove the "#" at the beginning of the line below
  # how_to_render_borders args
  # =======================================================================


  # ==== HOW TO RENDER A LINE =============================================
  # Remove the "#" at the beginning of the line below
  # how_to_render_lines args
  # =======================================================================


  # == HOW TO RENDER A SPRITE =============================================
  # Remove the "#" at the beginning of the line below
  # how_to_render_sprites args
  # =======================================================================


  # ==== HOW TO MOVE A SPRITE BASED OFF OF USER INPUT =====================
  # Remove the "#" at the beginning of the line below
  # how_to_move_a_sprite args
  # =======================================================================


  # ==== HOW TO ANIMATE A SPRITE (SEPERATE PNGS) ==========================
  # Remove the "#" at the beginning of the line below
  # how_to_animate_a_sprite args
  # =======================================================================


  # ==== HOW TO ANIMATE A SPRITE (SPRITE SHEET) ===========================
  # Remove the "#" at the beginning of the line below
  # how_to_animate_a_sprite_sheet args
  # =======================================================================


  # ==== HOW TO DETERMINE COLLISION =============================================
  # Remove the "#" at the beginning of the line below
  # how_to_determine_collision args
  # =======================================================================


  # ==== HOW TO CREATE BUTTONS ==================================================
  # Remove the "#" at the beginning of the line below
  # how_to_create_buttons args
  # =======================================================================


  # ==== The line below renders a debug grid, mouse information, and current tick
  render_debug args
end

def hello_world args
  args.lowrez.solids  << { x: 0, y: 64, w: 10, h: 10, r: 255 }

  args.lowrez.labels  << {
    x: 32,
    y: 63,
    text: "lowrezjam 2020",
    size_enum: LOWREZ_FONT_SM,
    alignment_enum: 1,
    r: 0,
    g: 0,
    b: 0,
    a: 255,
    font: LOWREZ_FONT_PATH
  }

  args.lowrez.sprites << {
    x: 32 - 10,
    y: 32 - 10,
    w: 20,
    h: 20,
    path: 'sprites/lowrez-ship-blue.png',
    a: args.state.tick_count % 255,
    angle: args.state.tick_count % 360
  }
end


# =======================================================================
# ==== HOW TO RENDER A LABEL ============================================
# =======================================================================
def how_to_render_a_label args
  # NOTE: Text is aligned from the TOP LEFT corner

  # Render an EXTRA LARGE/XL label (remove the "#" in front of each line below)
  args.lowrez.labels << { x: 0, y: 57, text: "Hello World",
                         size_enum: LOWREZ_FONT_XL,
                         r: 0, g: 0, b: 0, a: 255,
                         font: LOWREZ_FONT_PATH }

  # Render a LARGE/LG label (remove the "#" in front of each line below)
  args.lowrez.labels << { x: 0, y: 36, text: "Hello World",
                          size_enum: LOWREZ_FONT_LG,
                          r: 0, g: 0, b: 0, a: 255,
                          font: LOWREZ_FONT_PATH }

  # Render a MEDIUM/MD label (remove the "#" in front of each line below)
  args.lowrez.labels << { x: 0, y: 20, text: "Hello World",
                          size_enum: LOWREZ_FONT_MD,
                          r: 0, g: 0, b: 0, a: 255,
                          font: LOWREZ_FONT_PATH }

  # Render a SMALL/SM label (remove the "#" in front of each line below)
  args.lowrez.labels << { x: 0, y: 9, text: "Hello World",
                          size_enum: LOWREZ_FONT_SM,
                          r: 0, g: 0, b: 0, a: 255,
                          font: LOWREZ_FONT_PATH }

  # You are provided args.lowrez.default_label which returns a Hash that you
  # can ~merge~ properties with
  # Example 1
  args.lowrez.labels << args.lowrez
                            .default_label
                            .merge(text: "Default")

  # Example 2
  args.lowrez.labels << args.lowrez
                            .default_label
                            .merge(x: 31,
                                   text: "Default",
                                   r: 128,
                                   g: 128,
                                   b: 128)
end

## # =============================================================================
## # ==== HOW TO RENDER FILLED SQUARES (SOLIDS) ==================================
## # =============================================================================
def how_to_render_solids args
  # Render a red square at 0, 0 with a width and height of 1
  args.lowrez.solids << { x: 0, y: 0, w: 1, h: 1, r: 255, g: 0, b: 0, a: 255 }

  # Render a red square at 1, 1 with a width and height of 2
  args.lowrez.solids << { x: 1, y: 1, w: 2, h: 2, r: 255, g: 0, b: 0, a: 255 }

  # Render a red square at 3, 3 with a width and height of 3
  args.lowrez.solids << { x: 3, y: 3, w: 3, h: 3, r: 255, g: 0, b: 0 }

  # Render a red square at 6, 6 with a width and height of 4
  args.lowrez.solids << { x: 6, y: 6, w: 4, h: 4, r: 255, g: 0, b: 0 }
end

## # =============================================================================
## # ==== HOW TO RENDER UNFILLED SQUARES (BORDERS) ===============================
## # =============================================================================
def how_to_render_borders args
  # Render a red square at 0, 0 with a width and height of 3
  args.lowrez.borders << { x: 0, y: 0, w: 3, h: 3, r: 255, g: 0, b: 0, a: 255 }

  # Render a red square at 3, 3 with a width and height of 3
  args.lowrez.borders << { x: 3, y: 3, w: 4, h: 4, r: 255, g: 0, b: 0, a: 255 }

  # Render a red square at 5, 5 with a width and height of 4
  args.lowrez.borders << { x: 7, y: 7, w: 5, h: 5, r: 255, g: 0, b: 0, a: 255 }
end

## # =============================================================================
## # ==== HOW TO RENDER A LINE ===================================================
## # =============================================================================
def how_to_render_lines args
  # Render a horizontal line at the bottom
  args.lowrez.lines << { x: 0, y: 0, x2: 63, y2:  0, r: 255 }

  # Render a vertical line at the left
  args.lowrez.lines << { x: 0, y: 0, x2:  0, y2: 63, r: 255 }

  # Render a diagonal line starting from the bottom left and going to the top right
  args.lowrez.lines << { x: 0, y: 0, x2: 63, y2: 63, r: 255 }
end

## # =============================================================================
## # == HOW TO RENDER A SPRITE ===================================================
## # =============================================================================
def how_to_render_sprites args
  # Loop 10 times and create 10 sprites in 10 positions
  # Render a sprite at the bottom left with a width and height of 5 and a path of 'sprites/lowrez-ship-blue.png'
  10.times do |i|
    args.lowrez.sprites << {
      x: i * 5,
      y: i * 5,
      w: 5,
      h: 5,
      path: 'sprites/lowrez-ship-blue.png'
    }
  end

  # Given an array of positions create sprites
  positions = [
    { x: 10, y: 42 },
    { x: 15, y: 45 },
    { x: 22, y: 33 },
  ]

  positions.each do |position|
    # use Ruby's ~Hash#merge~ function to create a sprite
    args.lowrez.sprites << position.merge(path: 'sprites/lowrez-ship-red.png',
                                          w: 5,
                                          h: 5)
  end
end

## # =============================================================================
## # ==== HOW TO ANIMATE A SPRITE (SEPERATE PNGS) ==========================
## # =============================================================================
def how_to_animate_a_sprite args
  # STEP 1: Define when you want the animation to start. The animation in this case will start in 3 seconds
  start_animation_on_tick = 180

  # STEP 2: Get the frame_index given the start tick.
  sprite_index = start_animation_on_tick.frame_index count: 7,     # how many sprites?
                                                     hold_for: 4,  # how long to hold each sprite?
                                                     repeat: true  # should it repeat?

  # STEP 3: frame_index will return nil if the frame hasn't arrived yet
  if sprite_index
    # if the sprite_index is populated, use it to determine the sprite path and render it
    sprite_path  = "sprites/explosion-#{sprite_index}.png"
    args.lowrez.sprites << { x: 0, y: 0, w: 64, h: 64, path: sprite_path }
  else
    # if the sprite_index is nil, render a countdown instead
    countdown_in_seconds = ((start_animation_on_tick - args.state.tick_count) / 60).round(1)

    args.lowrez.labels  << args.lowrez
                               .default_label
                               .merge(x: 32,
                                      y: 32,
                                      text: "Count Down: #{countdown_in_seconds}",
                                      alignment_enum: 1)
  end

  # render the current tick and the resolved sprite index
  args.lowrez.labels  << args.lowrez
                               .default_label
                               .merge(x: 0,
                                      y: 11,
                                      text: "Tick: #{args.state.tick_count}")
  args.lowrez.labels  << args.lowrez
                               .default_label
                               .merge(x: 0,
                                      y: 5,
                                      text: "sprite_index: #{sprite_index}")
end

## # =============================================================================
## # ==== HOW TO ANIMATE A SPRITE (SPRITE SHEET) =================================
## # =============================================================================
def how_to_animate_a_sprite_sheet args
  # STEP 1: Define when you want the animation to start. The animation in this case will start in 3 seconds
  start_animation_on_tick = 180

  # STEP 2: Get the frame_index given the start tick.
  sprite_index = start_animation_on_tick.frame_index count: 7,     # how many sprites?
                                                     hold_for: 4,  # how long to hold each sprite?
                                                     repeat: true  # should it repeat?

  # STEP 3: frame_index will return nil if the frame hasn't arrived yet
  if sprite_index
    # if the sprite_index is populated, use it to determine the source rectangle and render it
    args.lowrez.sprites << {
      x: 0,
      y: 0,
      w: 64,
      h: 64,
      path:  "sprites/explosion-sheet.png",
      source_x: 32 * sprite_index,
      source_y: 0,
      source_w: 32,
      source_h: 32
    }
  else
    # if the sprite_index is nil, render a countdown instead
    countdown_in_seconds = ((start_animation_on_tick - args.state.tick_count) / 60).round(1)

    args.lowrez.labels  << args.lowrez
                               .default_label
                               .merge(x: 32,
                                      y: 32,
                                      text: "Count Down: #{countdown_in_seconds}",
                                      alignment_enum: 1)
  end

  # render the current tick and the resolved sprite index
  args.lowrez.labels  << args.lowrez
                               .default_label
                               .merge(x: 0,
                                      y: 11,
                                      text: "tick: #{args.state.tick_count}")
  args.lowrez.labels  << args.lowrez
                               .default_label
                               .merge(x: 0,
                                      y: 5,
                                      text: "sprite_index: #{sprite_index}")
end

## # =============================================================================
## # ==== HOW TO STORE STATE, ACCEPT INPUT, AND RENDER SPRITE BASED OFF OF STATE =
## # =============================================================================
def how_to_move_a_sprite args
  args.lowrez.labels << args.lowrez
                            .default_label
                            .merge(x: 32,
                                   y: 62, text: "Use Arrow Keys",
                                   alignment_enum: 1)

  args.lowrez.labels << args.lowrez
                            .default_label
                            .merge(x: 32,
                                   y: 56, text: "Use WASD",
                                   alignment_enum: 1)

  args.lowrez.labels << args.lowrez
                            .default_label
                            .merge(x: 32,
                                   y: 50, text: "Or Click",
                                   alignment_enum: 1)

  # set the initial values for x and y using ||= ("or equal operator")
  args.state.ship.x ||= 0
  args.state.ship.y ||= 0

  # if a mouse click occurs, update the ship's x and y to be the location of the click
  if args.lowrez.mouse_click
    args.state.ship.x = args.lowrez.mouse_click.x
    args.state.ship.y = args.lowrez.mouse_click.y
  end

  # if a or left arrow is pressed/held, decrement the ships x position
  if args.lowrez.keyboard.left
    args.state.ship.x -= 1
  end

  # if d or right arrow is pressed/held, increment the ships x position
  if args.lowrez.keyboard.right
    args.state.ship.x += 1
  end

  # if s or down arrow is pressed/held, decrement the ships y position
  if args.lowrez.keyboard.down
    args.state.ship.y -= 1
  end

  # if w or up arrow is pressed/held, increment the ships y position
  if args.lowrez.keyboard.up
    args.state.ship.y += 1
  end

  # render the sprite to the screen using the position stored in args.state.ship
  args.lowrez.sprites << {
    x: args.state.ship.x,
    y: args.state.ship.y,
    w: 5,
    h: 5,
    path: 'sprites/lowrez-ship-blue.png',
    # parameters beyond this point are optional
    angle: 0, # Note: rotation angle is denoted in degrees NOT radians
    r: 255,
    g: 255,
    b: 255,
    a: 255
  }
end

# =======================================================================
# ==== HOW TO DETERMINE COLLISION =======================================
# =======================================================================
def how_to_determine_collision args
  # Render the instructions
  args.lowrez.labels << args.lowrez
                            .default_label
                            .merge(x: 32,
                                   y: 62, text: "Click Anywhere",
                                   alignment_enum: 1)

  # if a mouse click occurs:
  # - set ship_one if it isn't set
  # - set ship_two if it isn't set
  # - otherwise reset ship one and ship two
  if args.lowrez.mouse_click
    # is ship_one set?
    if !args.state.ship_one
      args.state.ship_one = { x: args.lowrez.mouse_click.x - 10,
                              y: args.lowrez.mouse_click.y - 10,
                              w: 20,
                              h: 20 }
    # is ship_one set?
    elsif !args.state.ship_two
      args.state.ship_two = { x: args.lowrez.mouse_click.x - 10,
                              y: args.lowrez.mouse_click.y - 10,
                              w: 20,
                              h: 20 }
    # should we reset?
    else
      args.state.ship_one = nil
      args.state.ship_two = nil
    end
  end

  # render ship one if it's set
  if args.state.ship_one
    # use Ruby's .merge method which is available on ~Hash~ to set the sprite and alpha
    # render ship one
    args.lowrez.sprites << args.state.ship_one.merge(path: 'sprites/lowrez-ship-blue.png', a: 100)
  end

  if args.state.ship_two
    # use Ruby's .merge method which is available on ~Hash~ to set the sprite and alpha
    # render ship two
    args.lowrez.sprites << args.state.ship_two.merge(path: 'sprites/lowrez-ship-red.png', a: 100)
  end

  # if both ship one and ship two are set, then determine collision
  if args.state.ship_one && args.state.ship_two
    # collision is determined using the intersect_rect? method
    if args.state.ship_one.intersect_rect? args.state.ship_two
      # if collision occurred, render the words collision!
      args.lowrez.labels << args.lowrez
                            .default_label
                            .merge(x: 31,
                                   y: 5,
                                   text: "Collision!",
                                   alignment_enum: 1)
    else
      # if collision occurred, render the words no collision.
      args.lowrez.labels << args.lowrez
                            .default_label
                            .merge(x: 31,
                                   y: 5,
                                   text: "No Collision.",
                                   alignment_enum: 1)
    end
  else
    # if both ship one and ship two aren't set, then render --
      args.lowrez.labels << args.lowrez
                            .default_label
                            .merge(x: 31,
                                   y: 6,
                                   text: "--",
                                   alignment_enum: 1)
  end
end

## # =============================================================================
## # ==== HOW TO CREATE BUTTONS ==================================================
## # =============================================================================
def how_to_create_buttons args
  # Define a button style
  args.state.button_style = { w: 62, h: 10, r: 80, g: 80, b: 80 }
  args.state.label_style  = { r: 80, g: 80, b: 80 }

  # Render instructions
  args.state.button_message ||= "Press a Button!"
  args.lowrez.labels << args.lowrez
                            .default_label
                            .merge(args.state.label_style)
                            .merge(x: 32,
                                   y: 62,
                                   text: args.state.button_message,
                                   alignment_enum: 1)


  # Creates button one using a border and a label
  args.state.button_one_border = args.state.button_style.merge( x: 1, y: 32)
  args.lowrez.borders << args.state.button_one_border
  args.lowrez.labels  << args.lowrez
                             .default_label
                             .merge(args.state.label_style)
                             .merge(x: args.state.button_one_border.x + 2,
                                    y: args.state.button_one_border.y + LOWREZ_FONT_SM_HEIGHT + 2,
                                    text: "Button One")

  # Creates button two using a border and a label
  args.state.button_two_border = args.state.button_style.merge( x: 1, y: 20)

  args.lowrez.borders << args.state.button_two_border
  args.lowrez.labels << args.lowrez
                            .default_label
                            .merge(args.state.label_style)
                            .merge(x: args.state.button_two_border.x + 2,
                                   y: args.state.button_two_border.y + LOWREZ_FONT_SM_HEIGHT + 2,
                                   text: "Button Two")

  # Initialize the state variable that tracks which button was clicked to "" (empty stringI
  args.state.last_button_clicked ||= "--"

  # If a click occurs, check to see if either button one, or button two was clicked
  # using the inside_rect? method of the mouse
  # set args.state.last_button_clicked accordingly
  if args.lowrez.mouse_click
    if args.lowrez.mouse_click.inside_rect? args.state.button_one_border
      args.state.last_button_clicked = "One Clicked!"
    elsif args.lowrez.mouse_click.inside_rect? args.state.button_two_border
      args.state.last_button_clicked = "Two Clicked!"
    else
      args.state.last_button_clicked = "--"
    end
  end

  # Render the current value of args.state.last_button_clicked
  args.lowrez.labels << args.lowrez
                             .default_label
                             .merge(args.state.label_style)
                             .merge(x: 32,
                                    y: 5,
                                    text: args.state.last_button_clicked,
                                    alignment_enum: 1)
end


def render_debug args
  if !args.state.grid_rendered
    65.map_with_index do |i|
      args.outputs.static_debug << {
        x:  LOWREZ_X_OFFSET,
        y:  LOWREZ_Y_OFFSET + (i * 10),
        x2: LOWREZ_X_OFFSET + LOWREZ_ZOOMED_SIZE,
        y2: LOWREZ_Y_OFFSET + (i * 10),
        r: 128,
        g: 128,
        b: 128,
        a: 80
      }.line!

      args.outputs.static_debug << {
        x:  LOWREZ_X_OFFSET + (i * 10),
        y:  LOWREZ_Y_OFFSET,
        x2: LOWREZ_X_OFFSET + (i * 10),
        y2: LOWREZ_Y_OFFSET + LOWREZ_ZOOMED_SIZE,
        r: 128,
        g: 128,
        b: 128,
        a: 80
      }.line!
    end
  end

  args.state.grid_rendered = true

  args.state.last_click ||= 0
  args.state.last_up    ||= 0
  args.state.last_click   = args.state.tick_count if args.lowrez.mouse_down # you can also use args.lowrez.click
  args.state.last_up      = args.state.tick_count if args.lowrez.mouse_up
  args.state.label_style  = { size_enum: -1.5 }

  args.state.watch_list = [
    "args.state.tick_count is:       #{args.state.tick_count}",
    "args.lowrez.mouse_position is:  #{args.lowrez.mouse_position.x}, #{args.lowrez.mouse_position.y}",
    "args.lowrez.mouse_down tick:    #{args.state.last_click || "never"}",
    "args.lowrez.mouse_up tick:      #{args.state.last_up || "false"}",
  ]

  args.outputs.debug << args.state
                            .watch_list
                            .map_with_index do |text, i|
    {
      x: 5,
      y: 720 - (i * 20),
      text: text,
      size_enum: -1.5
    }.label!
  end

  args.outputs.debug << {
    x: 640,
    y:  25,
    text: "INFO: dev mode is currently enabled. Comment out the invocation of ~render_debug~ within the ~tick~ method to hide the debug layer.",
    size_enum: -0.5,
    alignment_enum: 1
  }.label!
end

$gtk.reset
