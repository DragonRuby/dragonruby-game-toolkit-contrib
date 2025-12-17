class Game
  attr_gtk

  GREEN = { r: 98, g: 140, b: 84 }
  YELLOW = { r: 177, g: 159, b: 54 }
  GRAY = { r: 64, g: 64, b: 64 }

  def initialize
    # get the list of words that can be inputed
    @valid_words = GTK.read_file("data/valid.txt")
                      .each_line
                      .map { |l| l.strip }
                      .reject { |l| l.length == 0 }

    # get the list of words that will be picked from
    @play_words = GTK.read_file("data/play.txt")
                      .each_line
                      .map { |l| l.strip }
                      .reject { |l| l.length == 0 }

    @player_progress = (GTK.read_file("user-data/progress.txt") || "")
                         .each_line
                         .map { |l| l.strip }
                         .reject { |l| l.length == 0 }
                         .map do |l|
                           word, result = l.split ","
                           { word: word, result: result.to_sym }
                         end

    # animation spline for when a letter is typed
    @enter_char_spline_duration = 15
    @enter_char_spline = [
      [0.0, 0.0,  0.66, 1.0],
      [1.0, 1.0,  1.0,  1.0],
      [1.0, 0.33, 0.0,  0.0]
    ]

    # animation spline for when a letter is flipped
    @flip_spline_duration = 15
    @flip_spline = [
      [1.0, 0.66, 0.33, 0.0],
      [0.0, 0.33, 0.66, 1.0],
    ]

    # animation spline for an invalid word
    @invalid_spline_duration = 15
    @invalid_spline = [
      [0.0, -0.5, 0.0, 0.5],
      [0.0, -0.5, 0.0, 0.5],
    ]

    # start a new game
    new_game!
  end

  def save_progress!
    content = @player_progress.map do |h|
      "#{h.word},#{h.result}"
    end.join "\n"

    GTK.write_file "user-data/progress.txt", content
  end

  def new_game!
    # from the list of playable words, choose a word
    @target_word = @play_words.reject do |w|
      @player_progress.any? { |h| h.word == w }
    end.sample

    # this is a look up table for coloring the keys
    @key_colors = { }

    # the current row the player is on
    @current_guess_index = 0

    # the current char the player is on
    @current_guess_char_index = 0

    # point at which the game has ended
    @game_over_at = nil

    # flag for when the game has endend
    @game_over = false

    # flag denoting whether the player won or lost when the game has ended
    @winner = false

    @new_game_at = Kernel.tick_count

    # data structure for where the guesses will be stored,
    # { rect:, action:, action_at:, char: }

    # Layout api is used to create the board
    @guesses = [
      [
        { rect: Layout.rect(row: 4, col: 1, w: 2, h: 2) },
        { rect: Layout.rect(row: 4, col: 3, w: 2, h: 2) },
        { rect: Layout.rect(row: 4, col: 5, w: 2, h: 2) },
        { rect: Layout.rect(row: 4, col: 7, w: 2, h: 2) },
        { rect: Layout.rect(row: 4, col: 9, w: 2, h: 2) },
      ],
      [
        { rect: Layout.rect(row: 6, col: 1, w: 2, h: 2) },
        { rect: Layout.rect(row: 6, col: 3, w: 2, h: 2) },
        { rect: Layout.rect(row: 6, col: 5, w: 2, h: 2) },
        { rect: Layout.rect(row: 6, col: 7, w: 2, h: 2) },
        { rect: Layout.rect(row: 6, col: 9, w: 2, h: 2) },
      ],
      [
        { rect: Layout.rect(row: 8, col: 1, w: 2, h: 2) },
        { rect: Layout.rect(row: 8, col: 3, w: 2, h: 2) },
        { rect: Layout.rect(row: 8, col: 5, w: 2, h: 2) },
        { rect: Layout.rect(row: 8, col: 7, w: 2, h: 2) },
        { rect: Layout.rect(row: 8, col: 9, w: 2, h: 2) },
      ],
      [
        { rect: Layout.rect(row: 10, col: 1, w: 2, h: 2) },
        { rect: Layout.rect(row: 10, col: 3, w: 2, h: 2) },
        { rect: Layout.rect(row: 10, col: 5, w: 2, h: 2) },
        { rect: Layout.rect(row: 10, col: 7, w: 2, h: 2) },
        { rect: Layout.rect(row: 10, col: 9, w: 2, h: 2) },
      ],
      [
        { rect: Layout.rect(row: 12, col: 1, w: 2, h: 2) },
        { rect: Layout.rect(row: 12, col: 3, w: 2, h: 2) },
        { rect: Layout.rect(row: 12, col: 5, w: 2, h: 2) },
        { rect: Layout.rect(row: 12, col: 7, w: 2, h: 2) },
        { rect: Layout.rect(row: 12, col: 9, w: 2, h: 2) },
      ],
      [
        { rect: Layout.rect(row: 14, col: 1, w: 2, h: 2) },
        { rect: Layout.rect(row: 14, col: 3, w: 2, h: 2) },
        { rect: Layout.rect(row: 14, col: 5, w: 2, h: 2) },
        { rect: Layout.rect(row: 14, col: 7, w: 2, h: 2) },
        { rect: Layout.rect(row: 14, col: 9, w: 2, h: 2) },
      ],
    ]

    # generate the keyboard layout and wire up the button callbacks
    @keyboard =  [
      *keyboard_buttons(17.25 + 1.5 * 0, 0, ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]),
      *keyboard_buttons(17.25 + 1.5 * 1, 0.6, ["A", "S", "D", "F", "G", "H", "J", "K", "L"]),
      *keyboard_buttons(17.25 + 1.5 * 2, 0, ["ENT", "Z", "X", "C", "V", "B", "N", "M", "BKSP"],
                        {
                          "ENT" => lambda { guess_word! },
                          "BKSP" => lambda { unset_char! }
                        })
    ]
  end

  def guess_word!
    # when the player presses enter, or clicks the "ENT" button

    # get the full word for the current row
    full_word = @guesses[@current_guess_index].map { |guess| guess.char }.join

    # the word is valid if its length is 5 and it's in the valid word dictionary
    is_valid = full_word.length == 5 && @valid_words.include?(full_word)

    # if it's valid, then enumerate each one of the guess entries and queue up
    # their animations
    if is_valid
      @guesses[@current_guess_index].each_with_index do |guess, i|
        if @target_word[i] == guess.char
          # if the index of the word matches exactly, then flip to green
          guess.action = :flip_green
          guess.action_at = Kernel.tick_count + i * @flip_spline_duration

          # update the keyboard color lookup and queue it to be rendered
          # after all animations have completed
          if !@key_colors[guess.char] || @key_colors[guess.char].color_id == :yellow || @key_colors[guess.char].color_id == :gray
            @key_colors[guess.char] ||= { **GREEN, at: Kernel.tick_count + 5 * @flip_spline_duration, color_id: :green }
          end
        elsif @target_word.include? guess.char
          # if the target word contains the character, then flip to yellow
          guess.action = :flip_yellow
          guess.action_at = Kernel.tick_count + i * @flip_spline_duration

          # update the keyboard color lookup and queue it to be rendered
          # after all animations have completed
          if !@key_colors[guess.char] || @key_colors[guess.char].color_id == :gray
            @key_colors[guess.char] ||= { **YELLOW, at: Kernel.tick_count + 5 * @flip_spline_duration, color_id: :yellow }
          end
        else
          # otherwise flip to gray
          guess.action = :flip_gray
          guess.action_at = Kernel.tick_count + i * @flip_spline_duration

          # update the keyboard color lookup and queue it to be rendered
          # after all animations have completed
          if !@key_colors[guess.char]
            @key_colors[guess.char] ||= { **GRAY, at: Kernel.tick_count + 5 * @flip_spline_duration, color_id: :gray }
          end
        end
      end

      if full_word == @target_word
        # the player has won if their guess matches the target word
        @game_over = true
        @game_over_at = Kernel.tick_count + 5 * @flip_spline_duration
        @winner = true

        @player_progress << { word: @target_word, result: :win }
      elsif @current_guess_index == 5
        # the player has lost if they've run out of rows
        @game_over = true
        @game_over_at = Kernel.tick_count + 5 * @flip_spline_duration
        @winner = false

        @player_progress << { word: @target_word, result: :loss }
      else
        # increment to the next row after the guess
        @current_guess_index += 1
        @current_guess_char_index = 0
      end
    else
      # if the word they selected isn't in the valid word dictionary,
      # then queue the invalid animation
      @guesses[@current_guess_index].each_with_index do |guess, i|
        guess.action = :invalid
        guess.action_at = Kernel.tick_count
      end
    end
  end

  def generate_letter_prefabs!
    # on frame zero, generate textures/glpyhs for all the letters
    return if Kernel.tick_count != 0

    r = Layout.rect(row: 0, col: 0, w: 2, h: 2)
    ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P",
     "A", "S", "D", "F", "G", "H", "J", "K", "L",
     "Z", "X", "C", "V", "B", "N", "M"].each do |c|
       outputs[c.downcase].w = r.w
       outputs[c.downcase].h = r.h
       outputs[c.downcase].background_color = [0, 0, 0, 0]
       outputs[c.downcase].primitives << { x: r.w / 2, y: r.h / 2, text: c, anchor_x: 0.5, anchor_y: 0.5, size_px: r.h / 2, r: 255, g: 255, b: 255 }
     end
  end

  def calc
    return if @game_over_at && @game_over_at.elapsed_time < 30
    return if @new_game_at && @new_game_at.elapsed_time < 30

    if @game_over
      # if they clicked or pressed enter, then start a new game
      if inputs.mouse.click || inputs.keyboard.key_up.char == "\r" || inputs.keyboard.key_down == "\r"
        save_progress!
        new_game!
      end
    else
      if inputs.mouse.click
        # if they are using the mouse and they click, find the key that the mouse intersects with
        keyboard_key = Geometry.find_intersect_rect(inputs.mouse, @keyboard, using: :rect)

        # if the key is found, then call the on_click callback on the key
        if keyboard_key
          keyboard_key.on_click.call
        end
      elsif inputs.keyboard.key_up.char

        # if they used the keyboard and it's backspace or enter,
        # then delete or guess word
        if inputs.keyboard.key_up.char == "\b"
          unset_char!
        elsif inputs.keyboard.key_up.char == "\r"
          guess_word!
        else
          # if it's any other key, then check to see if the keyboard buttons has
          # the key that was pressed
          key = @keyboard.find do |k|
            k.char == inputs.keyboard.key_up.char.upcase
          end

          # if so, then invoke the on_click callback (as if they clicked it with the mouse)
          key.on_click.call if key
        end
      end
    end
  end

  def tick
    generate_letter_prefabs!
    calc
    render
    # outputs.primitives << Layout.debug_primitives(invert_colors: true)
  end

  def unset_char!
    # unsetting a char/deleting a char logic
    if @current_guess_char_index == 4 && @guesses[@current_guess_index][@current_guess_char_index].char
      # if it's the last spot and there is a char to be deleted, then clear out the char
      @guesses[@current_guess_index][@current_guess_char_index].char = nil
    elsif @current_guess_char_index == 0 && @guesses[@current_guess_index][@current_guess_char_index].char
      # if it's the first spot and there is a char to be deleted, then clear out the char
      @guesses[@current_guess_index][@current_guess_char_index].char = nil
    elsif @current_guess_char_index != 0
      # otherwise move back a spot, and clear out the char in that spot
      @current_guess_char_index -= 1
      @guesses[@current_guess_index][@current_guess_char_index].char = nil
    end
  end

  def set_char! c
    # set the current spot's char and increment to the next spot if they aren't already on the las
    # spot
    if !@guesses[@current_guess_index][@current_guess_char_index].char
      @guesses[@current_guess_index][@current_guess_char_index].char = c
      @guesses[@current_guess_index][@current_guess_char_index].action_at = Kernel.tick_count
      @guesses[@current_guess_index][@current_guess_char_index].action = :set_char
      @current_guess_char_index += 1 if @current_guess_char_index != 4
    end
  end

  def keyboard_buttons(start_row, start_col, chars, callback_overrides = {})
    # button construction
    # layout api is used to create the rectangle, and the call back is set to
    # set_char!(char) by default unless there is a callback override (eg for ENT and BKSP)
    running_col = 0
    chars.map_with_index do |c, i|
      w = if c.length > 1
            1.8
          else
            1.2
          end
      r = if c.length > 1
            Layout.rect(row: start_row, col: start_col + running_col, w: w, h: 1.5)
          else
            Layout.rect(row: start_row, col: start_col + running_col, w: w, h: 1.5)
          end
      running_col += w
      on_click = callback_overrides[c] || ->() { set_char! c }
      { rect: r, char: c, on_click: on_click }
    end
  end

  def guess_char_prefab guess_char
    # this is the prefab for rendering a tile

    # get the location of the spot and a char (if one is there)
    r = guess_char.rect
    c = guess_char.char

    # the default color for the tile is a grayish border
    # with a dark background, and the character texture (if the spot has a character set)
    border_color = if c
                     { r: 90, g: 90, b: 90 }
                   else
                     { r: 45, g: 45, b: 45 }
                   end

    outer_tile = r.center.merge(path: :solid, **border_color, w: r.w, h: r.h, anchor_x: 0.5, anchor_y: 0.5)
    inner_tile = r.center.merge(path: :solid, r: 18, g: 18, b: 18, w: r.w - 4, h: r.h - 4, anchor_x: 0.5, anchor_y: 0.5)
    label_prefab = r.center.merge(path: c.downcase, w: r.w, h: r.h, anchor_x: 0.5, anchor_y: 0.5) if c

    # sorting for rendering so that animations aren't behind other tiles (default is 0)
    sort_order = 0

    if guess_char.action_at && guess_char.action == :set_char
      # if an action as been queued, and the action is :set_char

      # use the enter_char_spline animation to compute the percentage
      perc = if guess_char.action_at && guess_char.action_at.elapsed_time < @enter_char_spline_duration
               Easing.spline(guess_char.action_at, Kernel.tick_count, @enter_char_spline_duration, @enter_char_spline)
             else
               0
             end

      # the percentage is used to scale the rect up, and back down
      label_prefab = r.center.merge(path: c.downcase, w: r.w + 32 * perc, h: r.h + 32 * perc, anchor_x: 0.5, anchor_y: 0.5) if c
      outer_tile = r.center.merge(path: :solid, **border_color, w: r.w + 32 * perc, h: r.h + 32 * perc, anchor_x: 0.5, anchor_y: 0.5)
      inner_tile = r.center.merge(path: :solid, r: 18, g: 18, b: 18, w: r.w - 4 + 32 * perc, h: r.h - 4 + 32 * perc, anchor_x: 0.5, anchor_y: 0.5)

      # set the sort order to 1 so that it renders at the top
      sort_order = 1
    elsif guess_char.action_at && guess_char.action == :flip_green
      # if the animation is flip to green, then use the flip animation spline to compute the percentage
      perc = if guess_char.action_at && guess_char.action_at.elapsed_time < @flip_spline_duration && guess_char.action_at.elapsed_time > 0
               Easing.spline(guess_char.action_at, Kernel.tick_count, @flip_spline_duration, @flip_spline)
             else
               1
             end

      # default colors before the flip/reveal occurs
      outer_tile_color = { r: 90, g: 90, b: 90 }
      inner_tile_color = { r: 18, g: 18, b: 18 }

      # half way through the animation, flip to green
      if guess_char.action_at.elapsed_time > @flip_spline_duration.idiv(2)
        outer_tile_color = GREEN
        inner_tile_color = GREEN
      end

      # the perc value is used to control the height of the prefab
      label_prefab = r.center.merge(path: c.downcase, w: r.w, h: r.h * perc, anchor_x: 0.5, anchor_y: 0.5) if c
      outer_tile = r.center.merge(path: :solid, w: r.w, h: r.h * perc, anchor_x: 0.5, anchor_y: 0.5, **outer_tile_color)
      inner_tile = r.center.merge(path: :solid, w: r.w - 4, h: (r.h - 4) * perc, anchor_x: 0.5, anchor_y: 0.5, **inner_tile_color)
      sort_order = 1
    elsif guess_char.action_at && guess_char.action == :flip_yellow
      # same as flip_green, but yellow color
      perc = if guess_char.action_at && guess_char.action_at.elapsed_time < @flip_spline_duration && guess_char.action_at.elapsed_time > 0
               Easing.spline(guess_char.action_at, Kernel.tick_count, @flip_spline_duration, @flip_spline)
             else
               1
             end

      outer_tile_color = { r: 90, g: 90, b: 90 }
      inner_tile_color = { r: 18, g: 18, b: 18 }

      if guess_char.action_at.elapsed_time > @flip_spline_duration.idiv(2)
        outer_tile_color = YELLOW
        inner_tile_color = YELLOW
      end

      label_prefab = r.center.merge(path: c.downcase, w: r.w, h: r.h * perc, anchor_x: 0.5, anchor_y: 0.5) if c
      outer_tile = r.center.merge(path: :solid, w: r.w, h: r.h * perc, anchor_x: 0.5, anchor_y: 0.5, **outer_tile_color)
      inner_tile = r.center.merge(path: :solid, w: r.w - 4, h: (r.h - 4) * perc, anchor_x: 0.5, anchor_y: 0.5, **inner_tile_color)
      sort_order = 1
    elsif guess_char.action_at && guess_char.action == :flip_gray
      # same logic as flip_green, but gray color
      perc = if guess_char.action_at && guess_char.action_at.elapsed_time < @flip_spline_duration && guess_char.action_at.elapsed_time > 0
               Easing.spline(guess_char.action_at, Kernel.tick_count, @flip_spline_duration, @flip_spline)
             else
               1
             end

      outer_tile_color = { r: 90, g: 90, b: 90 }
      inner_tile_color = { r: 18, g: 18, b: 18 }

      if guess_char.action_at.elapsed_time > @flip_spline_duration.idiv(2)
        outer_tile_color = GRAY
        inner_tile_color = GRAY
      end

      label_prefab = r.center.merge(path: c.downcase, w: r.w, h: r.h * perc, anchor_x: 0.5, anchor_y: 0.5) if c
      outer_tile = r.center.merge(path: :solid, w: r.w, h: r.h * perc, anchor_x: 0.5, anchor_y: 0.5, **outer_tile_color)
      inner_tile = r.center.merge(path: :solid, w: r.w - 4, h: (r.h - 4) * perc, anchor_x: 0.5, anchor_y: 0.5, **inner_tile_color)
      sort_order = 1
    elsif guess_char.action_at && guess_char.action == :invalid
      # if the animation that's queued is an invalid word,
      # compute the prec using the @invalid_spline
      perc = if guess_char.action_at && guess_char.action_at.elapsed_time < @invalid_spline_duration && guess_char.action_at.elapsed_time > 0
               Easing.spline(guess_char.action_at, Kernel.tick_count, @invalid_spline_duration, @invalid_spline)
             else
               0
             end

      # the perc value is used to shift the x value (shake animation)
      label_prefab = { x: r.center.x + 64 * perc, y: r.center.y, w: r.w, h: r.h, anchor_x: 0.5, anchor_y: 0.5, path: c.downcase } if c
      outer_tile = { x: r.center.x + 64 * perc, y: r.center.y, path: :solid, **border_color, w: r.w, h: r.h, anchor_x: 0.5, anchor_y: 0.5 }
      inner_tile = { x: r.center.x + 64 * perc, y: r.center.y, path: :solid, r: 18, g: 18, b: 18, w: r.w - 4, h: r.h - 4, anchor_x: 0.5, anchor_y: 0.5 }
      sort_order = 1
    end

    # return a structure that contains the sort order for rendering, and the prefab/primitives to render
    {
      sort_order: sort_order,
      prefab: [
        outer_tile,
        inner_tile,
        label_prefab
      ]
    }
  end

  def render
    # set the back ground color
    outputs.background_color = [18, 18, 18]

    # enumerate all the guesses, flat map the prefabs
    # then sort each prefab by the sort order
    # and shovel the prefab data into output.primitives
    outputs.primitives << @guesses.flat_map do |guess|
      guess.map do |guess_char|
        guess_char_prefab(guess_char)
      end
    end.sort_by { |pf_container| pf_container.sort_order }
       .map { |pf| pf.prefab }

    # render the keyboard
    outputs.primitives << @keyboard.map do |keyboard_key|
      c = keyboard_key.char
      r = keyboard_key.rect
      # the color of the key is set to a defualt gray, unless there is a color override
      # in the key_colors lookup (along with a time stamp of when to show the color -> we don't want to change the
      # color during the reveal of a guess)
      color = if @key_colors[keyboard_key.char] && @key_colors[keyboard_key.char].at < Kernel.tick_count
                @key_colors[keyboard_key.char]
              else
                { r: 131, g: 131, b: 131 }
              end

      # return the prefab for the key which is a combination of the color, plus a label representing the key
      [
        r.merge(path: :solid, **color),
        r.center.merge(text: c, anchor_x: 0.5, anchor_y: 0.5, r: 255, g: 255, b: 255, size_px: 40)
      ]
    end
  end
end

# boot up of game
def boot args
  args.state = {}
end

# top level tick function
def tick args
  $game ||= Game.new
  $game.args = args
  $game.tick
end

# reset logic used when hotloading
def reset args
  $game = nil
end

GTK.reset
