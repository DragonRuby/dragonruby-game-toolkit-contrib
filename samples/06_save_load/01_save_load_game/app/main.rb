=begin

 APIs listing that haven't been encountered in previous sample apps:

 - Symbol (:): Ruby object with a name and an internal ID. Symbols are useful
   because with a given symbol name, you can refer to the same object throughout
   a Ruby program.

   In this sample app, we're using symbols for our buttons. We have buttons that
   light fires, save, load, etc. Each of these buttons has a distinct symbol like
   :light_fire, :save_game, :load_game, etc.

 - to_sym: Returns the symbol corresponding to the given string; creates the symbol
   if it does not already exist.
   For example,
   'car'.to_sym
   would return the symbol :car.

 - last: Returns the last element of an array.

 Reminders:

 - num1.lesser(num2): finds the lower value of the given options.
   For example, in the statement
   a = 4.lesser(3)
   3 has a lower value than 4, which means that the value of a would be set to 3,
   but if the statement had been
   a = 4.lesser(5)
   4 has a lower value than 5, which means that the value of a would be set to 4.

 - num1.fdiv(num2): returns the float division (will have a decimal) of the two given numbers.
   For example, 5.fdiv(2) = 2.5 and 5.fdiv(5) = 1.0

 - String interpolation: uses #{} syntax; everything between the #{ and the } is evaluated
   as Ruby code, and the placeholder is replaced with its corresponding value or result.

 - args.outputs.labels: An array. Values generate a label.
   Parameters are [X, Y, TEXT, SIZE, ALIGN, RED, GREEN, BLUE, ALPHA, FONT STYLE]
   For more information, go to mygame/documentation/02-labels.md.

 - ARRAY#inside_rect?: An array with at least two values is considered a point. An array
   with at least four values is considered a rect. The inside_rect? function returns true
   or false depending on if the point is inside the rect.

=end

# This code allows users to perform different tasks, such as saving and loading the game.
# Users also have options to reset the game and light a fire.

class TextedBasedGame

  # Contains methods needed for game to run properly.
  # Increments tick count by 1 each time it runs (60 times in a single second)
  def tick
    default
    show_intro
    state.engine_tick_count += 1
    tick_fire
  end

  # Sets default values.
  # The ||= ensures that a variable's value is only set to the value following the = sign
  # if the value has not already been set before. Intialization happens only in the first frame.
  def default
    state.engine_tick_count ||= 0
    state.active_module     ||= :room
    state.fire_progress     ||= 0
    state.fire_ready_in     ||= 10
    state.previous_fire     ||= :dead
    state.fire              ||= :dead
  end

  def show_intro
    return unless state.engine_tick_count == 0 # return unless the game just started
    set_story_line "awake." # calls set_story_line method, sets to "awake"
  end

  # Sets story line.
  def set_story_line story_line
    state.story_line    = story_line # story line set to value of parameter
    state.active_module = :alert # active module set to alert
  end

  # Clears story line.
  def clear_storyline
    state.active_module = :none # active module set to none
    state.story_line = nil # story line is cleared, set to nil (or empty)
  end

  # Determines fire progress (how close the fire is to being ready to light).
  def tick_fire
    return if state.active_module == :alert # return if active module is alert
    state.fire_progress += 1 # increment fire progress
    # fire_ready_in is 10. The fire_progress is either the current value or 10, whichever has a lower value.
    state.fire_progress = state.fire_progress.lesser(state.fire_ready_in)
  end

  # Sets the value of fire (whether it is dead or roaring), and the story line
  def light_fire
    return unless fire_ready? # returns unless the fire is ready to be lit
    state.fire = :roaring # fire is lit, set to roaring
    state.fire_progress = 0 # the fire progress returns to 0, since the fire has been lit
    if state.fire != state.previous_fire
      set_story_line "the fire is #{state.fire}." # the story line is set using string interpolation
      state.previous_fire = state.fire
    end
  end

  # Checks if the fire is ready to be lit. Returns a boolean value.
  def fire_ready?
    # If fire_progress (value between 0 and 10) is equal to fire_ready_in (value of 10),
    # the fire is ready to be lit.
    state.fire_progress == state.fire_ready_in
  end

  # Divides the value of the fire_progress variable by 10 to determine how close the user is to
  # being able to light a fire.
  def light_fire_progress
    state.fire_progress.fdiv(10) # float division
  end

  # Defines fire as the state.fire variable.
  def fire
    state.fire
  end

  # Sets the title of the room.
  def room_title
    return "a room that is dark" if state.fire == :dead # room is dark if the fire is dead
    return "a room that is lit" # room is lit if the fire is not dead
  end

  # Sets the active_module to room.
  def go_to_room
    state.active_module = :room
  end

  # Defines active_module as the state.active_module variable.
  def active_module
    state.active_module
  end

  # Defines story_line as the state.story_line variable.
  def story_line
    state.story_line
  end

  # Update every 60 frames (or every second)
  def should_tick?
    state.tick_count.mod_zero?(60)
  end

  # Sets the value of the game state provider.
  def initialize game_state_provider
    @game_state_provider = game_state_provider
  end

  # Defines the game state.
  # Any variable prefixed with an @ symbol is an instance variable.
  def state
    @game_state_provider.state
  end

  # Saves the state of the game in a text file called game_state.txt.
  def save
    $gtk.serialize_state('game_state.txt', state)
  end

  # Loads the game state from the game_state.txt text file.
  # If the load is unsuccessful, the user is informed since the story line indicates the failure.
  def load
    parsed_state = $gtk.deserialize_state('game_state.txt')
    if !parsed_state
      set_story_line "no game to load. press save first."
    else
      $gtk.args.state = parsed_state
    end
  end

  # Resets the game.
  def reset
    $gtk.reset
  end
end

class TextedBasedGamePresenter
  attr_accessor :state, :outputs, :inputs

  # Creates empty collection called highlights.
  # Calls methods necessary to run the game.
  def tick
    state.layout.highlights ||= []
    game.tick if game.should_tick?
    render
    process_input
  end

  # Outputs a label of the tick count (passage of time) and calls all render methods.
  def render
    outputs.labels << [10, 30, state.tick_count]
    render_alert
    render_room
    render_highlights
  end

  # Outputs a label onto the screen that shows the story line, and also outputs a "close" button.
  def render_alert
    return unless game.active_module == :alert

    outputs.labels << [640, 480, game.story_line, 5, 1]  # outputs story line label
    outputs.primitives << button(:alert_dismiss, 490, 380, "close")  # positions "close" button under story line
  end

  def render_room
    return unless game.active_module == :room
    outputs.labels << [640, 700, game.room_title, 4, 1] # outputs room title label at top of screen

    # The parameters for these outputs are (symbol, x, y, text, value/percentage) and each has a y value
    # that positions it 60 pixels lower than the previous output.

    # outputs the light_fire_progress bar, uses light_fire_progress for its percentage (which changes bar's appearance)
    outputs.primitives << progress_bar(:light_fire, 490, 600, "light fire", game.light_fire_progress)
    outputs.primitives << button(       :save_game, 490, 540, "save") # outputs save button
    outputs.primitives << button(       :load_game, 490, 480, "load") # outputs load button
    outputs.primitives << button(      :reset_game, 490, 420, "reset") # outputs reset button
    outputs.labels << [640, 30, "the fire is #{game.fire}", 0, 1] # outputs fire label at bottom of screen
  end

  # Outputs a collection of highlights using an array to set their values, and also rejects certain values from the collection.
  def render_highlights
    state.layout.highlights.each do |h| # for each highlight in the collection
        h.lifetime -= 1 # decrease the value of its lifetime
      end

      outputs.solids << state.layout.highlights.map do |h| # outputs highlights collection
        [h.x, h.y, h.w, h.h, h.color, 255 * h.lifetime / h.max_lifetime] # sets definition for each highlight
        # transparency changes; divide lifetime by max_lifetime, multiply result by 255
      end

      # reject highlights from collection that have no remaining lifetime
      state.layout.highlights = state.layout.highlights.reject { |h| h.lifetime <= 0 }
  end

  # Checks whether or not a button was clicked.
  # Returns a boolean value.
  def process_input
    button = button_clicked? # calls button_clicked? method
  end

  # Returns a boolean value.
  # Finds the button that was clicked from the button list and determines what method to call.
  # Adds a highlight to the highlights collection.
  def button_clicked?
    return nil unless click_pos # return nil unless click_pos holds coordinates of mouse click
      button = @button_list.find do |k, v| # goes through button_list to find button clicked
        click_pos.inside_rect? v[:primitives].last.rect # was the mouse clicked inside the rect of button?
      end
      return unless button # return unless a button was clicked
      method_to_call = "#{button[0]}_clicked".to_sym # sets method_to_call to symbol (like :save_game or :load_game)
      if self.respond_to? method_to_call # returns true if self responds to the given method (method actually exists)
        border = button[1][:primitives].last # sets border definition using value of last key in button list hash

        # declares each highlight as a new entity, sets properties
        state.layout.highlights << state.new_entity(:highlight) do |h|
            h.x = border.x
            h.y = border.y
            h.w = border.w
            h.h = border.h
            h.max_lifetime = 10
            h.lifetime = h.max_lifetime
            h.color = [120, 120, 180] # sets color to shade of purple
          end

          self.send method_to_call # invoke method identified by symbol
        else # otherwise, if self doesn't respond to given method
          border = button[1][:primitives].last # sets border definition using value of last key in hash

          # declares each highlight as a new entity, sets properties
          state.layout.highlights << state.new_entity(:highlight) do |h|
            h.x = border.x
            h.y = border.y
            h.w = border.w
            h.h = border.h
            h.max_lifetime = 4 # different max_lifetime than the one set if respond_to? had been true
            h.lifetime = h.max_lifetime
            h.color = [120, 80, 80] # sets color to dark color
          end

          # instructions for users on how to add the missing method_to_call to the code
          puts "It looks like #{method_to_call} doesn't exists on TextedBasedGamePresenter. Please add this method:"
          puts "Just copy the code below and put it in the #{TextedBasedGamePresenter} class definition."
          puts ""
          puts "```"
          puts "class TextedBasedGamePresenter <--- find this class and put the method below in it"
          puts ""
          puts "  def #{method_to_call}"
          puts "    puts 'Yay that worked!'"
          puts "  end"
          puts ""
          puts "end <-- make sure to put the #{method_to_call} method in between the `class` word and the final `end` statement."
          puts "```"
          puts ""
      end
  end

  # Returns the position of the mouse when it is clicked.
  def click_pos
    return nil unless inputs.mouse.click # returns nil unless the mouse was clicked
    return inputs.mouse.click.point # returns location of mouse click (coordinates)
  end

  # Creates buttons for the button_list and sets their values using a hash (uses symbols as keys)
  def button id, x, y, text
    @button_list[id] ||= { # assigns values to hash keys
      id: id,
      text: text,
      primitives: [
        [x + 10, y + 30, text, 2, 0].label, # positions label inside border
        [x, y, 300, 50].border,             # sets definition of border
      ]
    }

    @button_list[id][:primitives] # returns label and border for buttons
  end

  # Creates a progress bar (used for lighting the fire) and sets its values.
  def progress_bar id, x, y, text, percentage
    @button_list[id] = { # assigns values to hash keys
      id: id,
      text: text,
      primitives: [
        [x, y, 300, 50, 100, 100, 100].solid, # sets definition for solid (which fills the bar with gray)
        [x + 10, y + 30, text, 2, 0].label, # sets definition for label, positions inside border
        [x, y, 300, 50].border, # sets definition of border
      ]
    }

    # Fills progress bar based on percentage. If the fire was ready to be lit (100%) and we multiplied by
    # 100, only 1/3 of the bar would only be filled in. 200 would cause only 2/3 to be filled in.
    @button_list[id][:primitives][0][2] = 300 * percentage
    @button_list[id][:primitives]
  end

  # Defines the game.
  def game
    @game
  end

  # Initalizes the game and creates an empty list of buttons.
  def initialize
    @game = TextedBasedGame.new self
    @button_list ||= {}
  end

  # Clears the storyline and takes the user to the room.
  def alert_dismiss_clicked
    game.clear_storyline
    game.go_to_room
  end

  # Lights the fire when the user clicks the "light fire" option.
  def light_fire_clicked
    game.light_fire
  end

  # Saves the game when the user clicks the "save" option.
  def save_game_clicked
    game.save
  end

  # Resets the game when the user clicks the "reset" option.
  def reset_game_clicked
    game.reset
  end

  # Loads the game when the user clicks the "load" option.
  def load_game_clicked
    game.load
  end
end

$text_based_rpg = TextedBasedGamePresenter.new

def tick args
  $text_based_rpg.state = args.state
  $text_based_rpg.outputs = args.outputs
  $text_based_rpg.inputs = args.inputs
  $text_based_rpg.tick
end
