require 'app/nokia.rb'

def tick args
  # =======================================================================
  # ==== HELLO WORLD ======================================================
  # =======================================================================
  # Steps to get started:
  # 1. ~def tick args~ is the entry point for your game.
  # 2. There are quite a few code samples below, remove the "##"
  #    before each line and save the file to see the changes.
  # 3. 0,  0 is in bottom left and 83, 47 is in top right corner.
  # 4. Be sure to come to the discord channel if you need
  #    more help: [[http://discord.dragonruby.org]].

  # Commenting and uncommenting code:
  # - Add a "#" infront of lines to comment out code
  # - Remove the "#" infront of lines to comment out code

  # Invoke the hello_world subroutine/method
  hello_world args # <---- add a "#" to the beginning of the line to stop running this subroutine/method.

  # =======================================================================
  # ==== HOW TO RENDER A LABEL ============================================
  # =======================================================================

  # Uncomment the line below to invoke the how_to_render_a_label subroutine/method.
  # Note: The method is defined in this file with the signature ~def how_to_render_a_label args~
  #       Scroll down to the method to see the details.

  # Remove the "#" at the beginning of the line below
  # how_to_render_a_label args # <---- remove the "#" at the beginning of this line to run the method


  # =======================================================================
  # ==== HOW TO RENDER A FILLED SQUARE (SOLID) ============================
  # =======================================================================
  # Remove the "#" at the beginning of the line below
  # how_to_render_solids args


  # =======================================================================
  # ==== HOW TO RENDER AN UNFILLED SQUARE (BORDER) ========================
  # =======================================================================
  # Remove the "#" at the beginning of the line below
  # how_to_render_borders args


  # =======================================================================
  # ==== HOW TO RENDER A LINE =============================================
  # =======================================================================
  # Remove the "#" at the beginning of the line below
  # how_to_render_lines args


  # =======================================================================
  # == HOW TO RENDER A SPRITE =============================================
  # =======================================================================
  # Remove the "#" at the beginning of the line below
  # how_to_render_sprites args


  # =======================================================================
  # ==== HOW TO MOVE A SPRITE BASED OFF OF USER INPUT =====================
  # =======================================================================
  # Remove the "#" at the beginning of the line below
  # how_to_move_a_sprite args


  # =======================================================================
  # ==== HOW TO ANIMATE A SPRITE (SEPERATE PNGS) ==========================
  # =======================================================================
  # Remove the "#" at the beginning of the line below
  # how_to_animate_a_sprite args


  # =======================================================================
  # ==== HOW TO ANIMATE A SPRITE (SPRITE SHEET) ===========================
  # =======================================================================
  # Remove the "#" at the beginning of the line below
  # how_to_animate_a_sprite_sheet args


  # =======================================================================
  # ==== HOW TO DETERMINE COLLISION =============================================
  # =======================================================================
  # Remove the "#" at the beginning of the line below
  # how_to_determine_collision args


  # =======================================================================
  # ==== HOW TO CREATE BUTTONS ==================================================
  # =======================================================================
  # Remove the "#" at the beginning of the line below
  # how_to_create_buttons args

  # ==== The line below renders a debug grid, mouse information, and current tick
  # render_debug args
end

# =======================================================================
# ==== HELLO WORLD ======================================================
# =======================================================================
def hello_world args
  args.nokia.solids  << { x: 0, y: 64, w: 10, h: 10, r: 255 }

  args.nokia.labels  << {
    x: 42,
    y: 46,
    text: "nokia 3310 jam 3",
    size_enum: NOKIA_FONT_SM,
    alignment_enum: 1,
    r: 0,
    g: 0,
    b: 0,
    a: 255,
    font: NOKIA_FONT_PATH
  }

  args.nokia.sprites << {
    x: 42 - 10,
    y: 26 - 10,
    w: 20,
    h: 20,
    path: 'sprites/monochrome-ship.png',
    a: 255,
    angle: args.state.tick_count % 360
  }
end

# =======================================================================
# ==== HOW TO RENDER A LABEL ============================================
# =======================================================================
def how_to_render_a_label args
  # NOTE: Text is aligned from the TOP LEFT corner

  # Render an EXTRA LARGE/XL label (remove the "#" in front of each line below)
  args.nokia.labels << { x: 0, y: 46, text: "Hello World",
                         size_enum: NOKIA_FONT_XL,
                         r: 0, g: 0, b: 0, a: 255,
                         font: NOKIA_FONT_PATH }

  # Render a LARGE/LG label (remove the "#" in front of each line below)
  args.nokia.labels << { x: 0, y: 29, text: "Hello World",
                          size_enum: NOKIA_FONT_LG,
                          r: 0, g: 0, b: 0, a: 255,
                          font: NOKIA_FONT_PATH }

  # Render a MEDIUM/MD label (remove the "#" in front of each line below)
  args.nokia.labels << { x: 0, y: 16, text: "Hello World",
                          size_enum: NOKIA_FONT_MD,
                          r: 0, g: 0, b: 0, a: 255,
                          font: NOKIA_FONT_PATH }

  # Render a SMALL/SM label (remove the "#" in front of each line below)
  args.nokia.labels << { x: 0, y: 7, text: "Hello World",
                          size_enum: NOKIA_FONT_SM,
                          r: 0, g: 0, b: 0, a: 255,
                          font: NOKIA_FONT_PATH }

  # You are provided args.nokia.default_label which returns a Hash that you
  # can ~merge~ properties with
  # Example 1
  args.nokia.labels << args.nokia
                            .default_label
                            .merge(text: "Default")

  # Example 2
  args.nokia.labels << args.nokia
                            .default_label
                            .merge(x: 31,
                                   text: "Default")
end

# =============================================================================
# ==== HOW TO RENDER FILLED SQUARES (SOLIDS) ==================================
# =============================================================================
def how_to_render_solids args
  # Render a square at 0, 0 with a width and height of 1
  args.nokia.solids << { x: 0, y: 0, w: 1, h: 1 }

  # Render a square at 1, 1 with a width and height of 2
  args.nokia.solids << { x: 1, y: 1, w: 2, h: 2 }

  # Render a square at 3, 3 with a width and height of 3
  args.nokia.solids << { x: 3, y: 3, w: 3, h: 3 }

  # Render a square at 6, 6 with a width and height of 4
  args.nokia.solids << { x: 6, y: 6, w: 4, h: 4 }
end

# =============================================================================
# ==== HOW TO RENDER UNFILLED SQUARES (BORDERS) ===============================
# =============================================================================
def how_to_render_borders args
  # Render a square at 0, 0 with a width and height of 3
  args.nokia.borders << { x: 0, y: 0, w: 3, h: 3, a: 255 }

  # Render a square at 3, 3 with a width and height of 3
  args.nokia.borders << { x: 3, y: 3, w: 4, h: 4, a: 255 }

  # Render a square at 5, 5 with a width and height of 4
  args.nokia.borders << { x: 7, y: 7, w: 5, h: 5, a: 255 }
end

# =============================================================================
# ==== HOW TO RENDER A LINE ===================================================
# =============================================================================
def how_to_render_lines args
  # Render a horizontal line at the bottom
  args.nokia.lines << { x: 0, y: 0, x2: 83, y2:  0 }

  # Render a vertical line at the left
  args.nokia.lines << { x: 0, y: 0, x2:  0, y2: 47 }

  # Render a diagonal line starting from the bottom left and going to the top right
  args.nokia.lines << { x: 0, y: 0, x2: 83, y2: 47 }
end

# =============================================================================
# == HOW TO RENDER A SPRITE ===================================================
# =============================================================================
def how_to_render_sprites args
  # Loop 10 times and create 10 sprites in 10 positions
  # Render a sprite at the bottom left with a width and height of 5 and a path of 'sprites/monochrome-ship.png'
  10.times do |i|
    args.nokia.sprites << {
      x: i * 8.4,
      y: i * 4.8,
      w: 5,
      h: 5,
      path: 'sprites/monochrome-ship.png'
    }
  end

  # Given an array of positions create sprites
  positions = [
    { x: 20, y: 32 },
    { x: 45, y: 15 },
    { x: 72, y: 23 },
  ]

  positions.each do |position|
    # use Ruby's ~Hash#merge~ function to create a sprite
    args.nokia.sprites << position.merge(path: 'sprites/monochrome-ship.png',
                                          w: 5,
                                          h: 5)
  end
end

# =============================================================================
# ==== HOW TO ANIMATE A SPRITE (SEPERATE PNGS) ==========================
# =============================================================================
def how_to_animate_a_sprite args
  # STEP 1: Define when you want the animation to start. The animation in this case will start in 3 seconds
  start_animation_on_tick = 180

  # STEP 2: Get the frame_index given the start tick.
  sprite_index = start_animation_on_tick.frame_index count: 7,     # how many sprites?
                                                     hold_for: 8,  # how long to hold each sprite?
                                                     repeat: true  # should it repeat?

  # STEP 3: frame_index will return nil if the frame hasn't arrived yet
  if sprite_index
    # if the sprite_index is populated, use it to determine the sprite path and render it
    sprite_path  = "sprites/explosion-#{sprite_index}.png"
    args.nokia.sprites << { x: 42 - 16,
                             y: 47 - 32,
                             w: 32,
                             h: 32,
                             path: sprite_path }
  else
    # if the sprite_index is nil, render a countdown instead
    countdown_in_seconds = ((start_animation_on_tick - args.state.tick_count) / 60).round(1)

    args.nokia.labels  << args.nokia
                               .default_label
                               .merge(x: 0,
                                      y: 18,
                                      text: "Count Down: #{countdown_in_seconds.to_sf}",
                                      alignment_enum: 0)
  end

  # render the current tick and the resolved sprite index
  args.nokia.labels  << args.nokia
                               .default_label
                               .merge(x: 0,
                                      y: 11,
                                      text: "Tick: #{args.state.tick_count}")
  args.nokia.labels  << args.nokia
                               .default_label
                               .merge(x: 0,
                                      y: 5,
                                      text: "sprite_index: #{sprite_index}")
end

# =============================================================================
# ==== HOW TO ANIMATE A SPRITE (SPRITE SHEET) =================================
# =============================================================================
def how_to_animate_a_sprite_sheet args
  # STEP 1: Define when you want the animation to start. The animation in this case will start in 3 seconds
  start_animation_on_tick = 180

  # STEP 2: Get the frame_index given the start tick.
  sprite_index = start_animation_on_tick.frame_index count: 7,     # how many sprites?
                                                     hold_for: 8,  # how long to hold each sprite?
                                                     repeat: true  # should it repeat?

  # STEP 3: frame_index will return nil if the frame hasn't arrived yet
  if sprite_index
    # if the sprite_index is populated, use it to determine the source rectangle and render it
    args.nokia.sprites << {
      x: 42 - 16,
      y: 47 - 32,
      w: 32,
      h: 32,
      path:  "sprites/explosion-sheet.png",
      source_x: 32 * sprite_index,
      source_y: 0,
      source_w: 32,
      source_h: 32
    }
  else
    # if the sprite_index is nil, render a countdown instead
    countdown_in_seconds = ((start_animation_on_tick - args.state.tick_count) / 60).round(1)

    args.nokia.labels  << args.nokia
                               .default_label
                               .merge(x: 0,
                                      y: 18,
                                      text: "Count Down: #{countdown_in_seconds.to_sf}",
                                      alignment_enum: 0)
  end

  # render the current tick and the resolved sprite index
  args.nokia.labels  << args.nokia
                               .default_label
                               .merge(x: 0,
                                      y: 11,
                                      text: "tick: #{args.state.tick_count}")
  args.nokia.labels  << args.nokia
                               .default_label
                               .merge(x: 0,
                                      y: 5,
                                      text: "sprite_index: #{sprite_index}")
end

# =============================================================================
# ==== HOW TO STORE STATE, ACCEPT INPUT, AND RENDER SPRITE BASED OFF OF STATE =
# =============================================================================
def how_to_move_a_sprite args
  args.nokia.labels << args.nokia
                            .default_label
                            .merge(x: 42,
                                   y: 46, text: "Use Arrow Keys",
                                   alignment_enum: 1)

  args.nokia.labels << args.nokia
                            .default_label
                            .merge(x: 42,
                                   y: 41, text: "Or WASD",
                                   alignment_enum: 1)

  args.nokia.labels << args.nokia
                            .default_label
                            .merge(x: 42,
                                   y: 36, text: "Or Click",
                                   alignment_enum: 1)

  # set the initial values for x and y using ||= ("or equal operator")
  args.state.ship.x ||= 0
  args.state.ship.y ||= 0

  # if a mouse click occurs, update the ship's x and y to be the location of the click
  if args.nokia.mouse_click
    args.state.ship.x = args.nokia.mouse_click.x
    args.state.ship.y = args.nokia.mouse_click.y
  end

  # if a or left arrow is pressed/held, decrement the ships x position
  if args.nokia.keyboard.left
    args.state.ship.x -= 1
  end

  # if d or right arrow is pressed/held, increment the ships x position
  if args.nokia.keyboard.right
    args.state.ship.x += 1
  end

  # if s or down arrow is pressed/held, decrement the ships y position
  if args.nokia.keyboard.down
    args.state.ship.y -= 1
  end

  # if w or up arrow is pressed/held, increment the ships y position
  if args.nokia.keyboard.up
    args.state.ship.y += 1
  end

  # render the sprite to the screen using the position stored in args.state.ship
  args.nokia.sprites << {
    x: args.state.ship.x,
    y: args.state.ship.y,
    w: 5,
    h: 5,
    path: 'sprites/monochrome-ship.png',
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
  args.nokia.labels << args.nokia
                            .default_label
                            .merge(x: 42,
                                   y: 46, text: "Click Anywhere",
                                   alignment_enum: 1)

  # if a mouse click occurs:
  # - set ship_one if it isn't set
  # - set ship_two if it isn't set
  # - otherwise reset ship one and ship two
  if args.nokia.mouse_click
    # is ship_one set?
    if !args.state.ship_one
      args.state.ship_one = { x: args.nokia.mouse_click.x - 5,
                              y: args.nokia.mouse_click.y - 5,
                              w: 10,
                              h: 10 }
    # is ship_one set?
    elsif !args.state.ship_two
      args.state.ship_two = { x: args.nokia.mouse_click.x - 5,
                              y: args.nokia.mouse_click.y - 5,
                              w: 10,
                              h: 10 }
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
    args.nokia.sprites << args.state.ship_one.merge(path: 'sprites/monochrome-ship.png')
  end

  if args.state.ship_two
    # use Ruby's .merge method which is available on ~Hash~ to set the sprite and alpha
    # render ship two
    args.nokia.sprites << args.state.ship_two.merge(path: 'sprites/monochrome-ship.png')
  end

  # if both ship one and ship two are set, then determine collision
  if args.state.ship_one && args.state.ship_two
    # collision is determined using the intersect_rect? method
    if args.state.ship_one.intersect_rect? args.state.ship_two
      # if collision occurred, render the words collision!
      args.nokia.labels << args.nokia
                            .default_label
                            .merge(x: 42,
                                   y: 5,
                                   text: "Collision!",
                                   alignment_enum: 1)
    else
      # if collision occurred, render the words no collision.
      args.nokia.labels << args.nokia
                            .default_label
                            .merge(x: 42,
                                   y: 5,
                                   text: "No Collision.",
                                   alignment_enum: 1)
    end
  else
    # if both ship one and ship two aren't set, then render --
      args.nokia.labels << args.nokia
                            .default_label
                            .merge(x: 42,
                                   y: 6,
                                   text: "--",
                                   alignment_enum: 1)
  end
end

# =============================================================================
# ==== HOW TO CREATE BUTTONS ==================================================
# =============================================================================
def how_to_create_buttons args
  # Define a button style
  args.state.button_style = { w: 82, h: 10, }

  # Render instructions
  args.state.button_message ||= "Press a Button!"
  args.nokia.labels << args.nokia
                            .default_label
                            .merge(x: 42,
                                   y: 82,
                                   text: args.state.button_message,
                                   alignment_enum: 1)


  # Creates button one using a border and a label
  args.state.button_one_border = args.state.button_style.merge( x: 1, y: 32)
  args.nokia.borders << args.state.button_one_border
  args.nokia.labels  << args.nokia
                             .default_label
                             .merge(x: args.state.button_one_border.x + 2,
                                    y: args.state.button_one_border.y + NOKIA_FONT_SM_HEIGHT + 2,
                                    text: "Button One")

  # Creates button two using a border and a label
  args.state.button_two_border = args.state.button_style.merge( x: 1, y: 20)

  args.nokia.borders << args.state.button_two_border
  args.nokia.labels << args.nokia
                            .default_label
                            .merge(x: args.state.button_two_border.x + 2,
                                   y: args.state.button_two_border.y + NOKIA_FONT_SM_HEIGHT + 2,
                                   text: "Button Two")

  # Initialize the state variable that tracks which button was clicked to "" (empty stringI
  args.state.last_button_clicked ||= "--"

  # If a click occurs, check to see if either button one, or button two was clicked
  # using the inside_rect? method of the mouse
  # set args.state.last_button_clicked accordingly
  if args.nokia.mouse_click
    if args.nokia.mouse_click.inside_rect? args.state.button_one_border
      args.state.last_button_clicked = "One Clicked!"
    elsif args.nokia.mouse_click.inside_rect? args.state.button_two_border
      args.state.last_button_clicked = "Two Clicked!"
    else
      args.state.last_button_clicked = "--"
    end
  end

  # Render the current value of args.state.last_button_clicked
  args.nokia.labels << args.nokia
                             .default_label
                             .merge(x: 42,
                                    y: 5,
                                    text: args.state.last_button_clicked,
                                    alignment_enum: 1)
end

def render_debug args
  if !args.state.grid_rendered
    (NOKIA_HEIGHT + 1).map_with_index do |i|
      args.outputs.static_debug << {
        x:  NOKIA_X_OFFSET,
        y:  NOKIA_Y_OFFSET + (i * NOKIA_ZOOM),
        x2: NOKIA_X_OFFSET + NOKIA_ZOOMED_WIDTH,
        y2: NOKIA_Y_OFFSET + (i * NOKIA_ZOOM),
        r: 128,
        g: 128,
        b: 128,
        a: 80
      }.line
    end

    (NOKIA_WIDTH + 1).map_with_index do |i|
      args.outputs.static_debug << {
        x:  NOKIA_X_OFFSET + (i * NOKIA_ZOOM),
        y:  NOKIA_Y_OFFSET,
        x2: NOKIA_X_OFFSET + (i * NOKIA_ZOOM),
        y2: NOKIA_Y_OFFSET + NOKIA_ZOOMED_HEIGHT,
        r: 128,
        g: 128,
        b: 128,
        a: 80
      }.line
    end
  end

  args.state.grid_rendered = true

  args.state.last_click ||= 0
  args.state.last_up    ||= 0
  args.state.last_click   = args.state.tick_count if args.nokia.mouse_down # you can also use args.nokia.click
  args.state.last_up      = args.state.tick_count if args.nokia.mouse_up
  args.state.label_style  = { size_enum: -1.5 }

  args.state.watch_list = [
    "args.state.tick_count is:      #{args.state.tick_count}",
    "args.nokia.mouse_position is:  #{args.nokia.mouse_position.x}, #{args.nokia.mouse_position.y}",
    "args.nokia.mouse_down tick:    #{args.state.last_click || "never"}",
    "args.nokia.mouse_up tick:      #{args.state.last_up || "false"}",
  ]

  args.outputs.debug << args.state
                            .watch_list
                            .map_with_index do |text, i|
    {
      x: 5,
      y: 720 - (i * 18),
      text: text,
      size_enum: -1.5,
      r: 255, g: 255, b: 255
    }.label!
  end

  args.outputs.debug << {
    x: 640,
    y:  25,
    text: "INFO: dev mode is currently enabled. Comment out the invocation of ~render_debug~ within the ~tick~ method to hide the debug layer.",
    size_enum: -0.5,
    alignment_enum: 1,
    r: 255, g: 255, b: 255
  }.label!
end

def snake_demo args

end

$gtk.reset
