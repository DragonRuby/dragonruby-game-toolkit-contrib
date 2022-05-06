=begin

 Reminders:

 - Hashes: Collection of unique keys and their corresponding values. The values can be found
   using their keys.

   In this sample app, the decisions needed for the game are stored in a hash. In fact, the
   decision.rb file contains hashes inside of other hashes!

   Each option is a key in the first hash, but also contains a hash (description and
   decision being its keys) as its value.
   Go into the decision.rb file and take a look before diving into the code below.

 - args.outputs.labels: An array. The values generate a label.
   The parameters are [X, Y, TEXT, SIZE, ALIGNMENT, RED, GREEN, BLUE, ALPHA, FONT STYLE]
   For more information about labels, go to mygame/documentation/02-labels.md.

 - args.keyboard.key_down.KEY: Determines if a key is in the down state or pressed down.
   For more information about the keyboard, go to mygame/documentation/06-keyboard.md.

 - String interpolation: uses #{} syntax; everything between the #{ and the } is evaluated
   as Ruby code, and the placeholder is replaced with its corresponding value or result.

=end

# This sample app provides users with a story and multiple decisions that they can choose to make.
# Users can make a decision using their keyboard, and the story will move forward based on user choices.

# The decisions available to users are stored in the decision.rb file.
# We must have access to it for the game to function properly.
GAME_FILE = 'app/decision.rb' # found in app folder

require GAME_FILE # require used to load another file, import class/method definitions

# Instructions are given using labels to users if they have not yet set up their story in the decision.rb file.
# Otherwise, the game is run.
def tick args
  if !args.state.loaded && !respond_to?(:game) # if game is not loaded and not responding to game symbol's method
    args.labels << [640, 370, 'Hey there! Welcome to Four Decisions.', 0, 1] # a welcome label is shown
    args.labels << [640, 340, 'Go to the file called decision.rb and tell me your story.', 0, 1]
  elsif respond_to?(:game) # otherwise, if responds to game
    args.state.loaded = true
    tick_game args # calls tick_game method, runs game
  end

  if args.state.tick_count.mod_zero? 60 # update every 60 frames
    t = args.gtk.ffi_file.mtime GAME_FILE # mtime returns modification time for named file
    if t != args.state.mtime
      args.state.mtime = t
      require GAME_FILE # require used to load file
      args.state.game_definition = nil # game definition and decision are empty
      args.state.decision_id = nil
    end
  end
end

# Runs methods needed for game to function properly
# Creates a rectangular border around the screen
def tick_game args
  defaults args
  args.borders << args.grid.rect
  render_decision args
  process_inputs args
end

# Sets default values and uses decision.rb file to define game and decision_id
# variable using the starting decision
def defaults args
  args.state.game_definition ||= game
  args.state.decision_id ||= args.state.game_definition[:starting_decision]
end

# Outputs the possible decision descriptions the user can choose onto the screen
# as well as what key to press on their keyboard to make their decision
def render_decision args
  decision = current_decision args
  # text is either the value of decision's description key or warning that no description exists
  args.labels << [640, 360, decision[:description] || "No definition found for #{args.state.decision_id}. Please update decision.rb.", 0, 1] # uses string interpolation

  # All decisions are stored in a hash
  # The descriptions output onto the screen are the values for the description keys of the hash.
  if decision[:option_one]
    args.labels << [10, 360, decision[:option_one][:description], 0, 0] # option one's description label
    args.labels << [10, 335, "(Press 'left' on the keyboard to select this decision)", -5, 0] # label of what key to press to select the decision
  end

  if decision[:option_two]
    args.labels << [1270, 360, decision[:option_two][:description], 0, 2] # option two's description
    args.labels << [1270, 335, "(Press 'right' on the keyboard to select this decision)", -5, 2]
  end

  if decision[:option_three]
    args.labels << [640, 45, decision[:option_three][:description], 0, 1] # option three's description
    args.labels << [640, 20, "(Press 'down' on the keyboard to select this decision)", -5, 1]
  end

  if decision[:option_four]
    args.labels << [640, 700, decision[:option_four][:description], 0, 1] # option four's description
    args.labels << [640, 675, "(Press 'up' on the keyboard to select this decision)", -5, 1]
  end
end

# Uses keyboard input from the user to make a decision
# Assigns the decision as the value of the decision_id variable
def process_inputs args
  decision = current_decision args # calls current_decision method

  if args.keyboard.key_down.left! && decision[:option_one] # if left key pressed and option one exists
    args.state.decision_id = decision[:option_one][:decision] # value of option one's decision hash key is set to decision_id
  end

  if args.keyboard.key_down.right! && decision[:option_two] # if right key pressed and option two exists
    args.state.decision_id = decision[:option_two][:decision] # value of option two's decision hash key is set to decision_id
  end

  if args.keyboard.key_down.down! && decision[:option_three] # if down key pressed and option three exists
    args.state.decision_id = decision[:option_three][:decision] # value of option three's decision hash key is set to decision_id
  end

  if args.keyboard.key_down.up! && decision[:option_four] # if up key pressed and option four exists
    args.state.decision_id = decision[:option_four][:decision] # value of option four's decision hash key is set to decision_id
  end
end

# Uses decision_id's value to keep track of current decision being made
def current_decision args
  args.state.game_definition[:decisions][args.state.decision_id] || {} # either has value or is empty
end

# Resets the game.
$gtk.reset
