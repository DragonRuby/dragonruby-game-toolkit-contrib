=begin

 APIs Listing that haven't been encountered in previous sample apps:

 - sample: Chooses random element from array.
   In this sample app, the target note is set by taking a sample from the collection
   of available notes.

 Reminders:
 - args.grid.(left|right|top|bottom): Pixel value for the boundaries of the virtual
   720 p screen (Dragon Ruby Game Toolkits's virtual resolution is always 1280x720).

 - args.state.new_entity: Used when we want to create a new object, like a sprite or button.
   For example, if we want to create a new button, we would declare it as a new entity and
   then define its properties.

 - String interpolation: Uses #{} syntax; everything between the #{ and the } is evaluated
   as Ruby code, and the placeholder is replaced with its corresponding value or result.

 - args.outputs.labels: An array. The values generate a label.
   The parameters are [X, Y, TEXT, SIZE, ALIGNMENT, RED, GREEN, BLUE, ALPHA, FONT STYLE]

 - reject: Removes elements from a collection if they meet certain requirements.

 - first: Returns the first element of an array.

 - inside_rect: Returns true or false depending on if the point is inside the rect.

 - to_sym: Returns symbol corresponding to string. Will create a symbol if it does
   not already exist.

=end

# This sample app allows users to test their musical skills by matching the piano sound that plays in each
# level to the correct note.

# Runs all the methods necessary for the game to function properly.
def tick args
  defaults args
  render args
  calc args
  input_mouse args
  tick_instructions args, "Sample app shows how to play sounds. args.outputs.sounds << \"path_to_wav.wav\""
end

# Sets default values and creates empty collections
# Initialization happens in the first frame only
def defaults _
  _.state.notes ||= []
  _.state.click_feedbacks ||= []
  _.state.current_level ||= 1
  _.state.times_wrong ||= 0 # when game starts, user hasn't guessed wrong yet
end

# Uses a label to display current level, and shows the score
# Creates a button to play the sample note, and displays the available notes that could be a potential match
def render _

  # grid.w_half positions the label in the horizontal center of the screen.
  _.outputs.labels << [_.grid.w_half, _.grid.top.shift_down(40), "Hole #{_.state.current_level} of 9", 0, 1, 0, 0, 0]

  render_score _ # shows score on screen

  if _.state.game_over # if game is over, a "play again" button is shown
    # Calculations ensure that Play Again label is displayed in center of border
    # Remove calculations from y parameters and see what happens to border and label placement
    _.state.play_again_border ||= _.state.with_meta([560, _.grid.h * 3 / 4 - 40, 160, 60], 'again') # array definition, text/title
    _.outputs.labels <<  [_.grid.w_half, _.grid.h * 3 / 4, "Play Again", 0, 1, 0, 0, 0] # outputs label
    _.outputs.borders << _.state.play_again_border # outputs border
  else # otherwise, if game is not over
    # Calculations ensure that label appears in center of border
    _.state.play_note_border ||= _.state.with_meta([560, _.grid.h * 3 / 4 - 40, 160, 60], 'play') # array definition, text/title
    _.outputs.labels <<  [_.grid.w_half, _.grid.h * 3 / 4, "Play Note ##{_.state.current_level}", 0, 1, 0, 0, 0] # outputs label
    _.outputs.borders << _.state.play_note_border # outputs border
  end

  return if _.state.game_over # return if game is over

  _.outputs.labels <<   [_.grid.w_half, 400, "I think the note is a(n)...",  0, 1, 0, 0, 0] # outputs label

  # Shows all of the available notes that can be potential matches.
  available_notes.each_with_index do |note, i|
    _.state.notes[i] ||= piano_button(_, note, i + 1) # calls piano_button method on each note (creates label and border)
    _.outputs.labels <<   _.state.notes[i].label # outputs note on screen with a label and a border
    _.outputs.borders <<  _.state.notes[i].border
  end

  # Shows whether or not the user is correct by filling the screen with either red or green
  _.outputs.solids << _.state.click_feedbacks.map { |c| c.solid }
end

# Shows the score (number of times the user guesses wrong) onto the screen using labels.
def render_score _
  if _.state.times_wrong == 0 # if the user has guessed wrong zero times, the score is par
    _.outputs.labels << [_.grid.w_half, _.grid.top.shift_down(80), "Score: PAR", 0, 1, 0, 0, 0]
  else # otherwise, number of times the user has guessed wrong is shown
    _.outputs.labels << [_.grid.w_half, _.grid.top.shift_down(80), "Score: +#{_.state.times_wrong}", 0, 1, 0, 0, 0] # shows score using string interpolation
  end
end

# Sets the target note for the level and performs calculations on click_feedbacks.
def calc _
  _.state.target_note ||= available_notes.sample # chooses a note from available_notes collection as target note
  _.state.click_feedbacks.each    { |c| c.solid[-1] -= 5 } # remove this line and solid color will remain on screen indefinitely
  # comment this line out and the solid color will keep flashing on screen instead of being removed from click_feedbacks collection
  _.state.click_feedbacks.reject! { |c| c.solid[-1] <= 0 }
end

# Uses input from the user to play the target note, as well as the other notes that could be a potential match.
def input_mouse _
  return unless _.inputs.mouse.click # return unless the mouse is clicked

  # finds button that was clicked by user
  button_clicked = _.outputs.borders.find_all do |b| # go through borders collection to find all borders that meet requirements
    _.inputs.mouse.click.point.inside_rect? b # find button border that mouse was clicked inside of
  end.reject {|b| !_.state.meta(b)}.first # reject, return first element

  return unless button_clicked # return unless button_clicked as a value (a button was clicked)

  queue_click_feedback _, # calls queue_click_feedback method on the button that was clicked
                       button_clicked.x,
                       button_clicked.y,
                       button_clicked.w,
                       button_clicked.h,
                       150, 100, 200 # sets color of button to shade of purple

  if _.state.meta(button_clicked) == 'play' # if "play note" button is pressed
    _.outputs.sounds << "sounds/#{_.state.target_note}.wav" # sound of target note is output
  elsif _.state.meta(button_clicked) == 'again' # if "play game again" button is pressed
    _.state.target_note = nil # no target note
    _.state.current_level = 1 # starts at level 1 again
    _.state.times_wrong = 0 # starts off with 0 wrong guesses
    _.state.game_over = false # the game is not over (because it has just been restarted)
  else # otherwise if neither of those buttons were pressed
    _.outputs.sounds << "sounds/#{_.state.meta(button_clicked)}.wav" # sound of clicked note is played
    if _.state.meta(button_clicked).to_sym == _.state.target_note # if clicked note is target note
      _.state.target_note = nil # target note is emptied

      if _.state.current_level < 9 # if game hasn't reached level 9
        _.state.current_level += 1 # game goes to next level
      else # otherwise, if game has reached level 9
        _.state.game_over = true # the game is over
      end

      queue_click_feedback _, 0, 0, _.grid.w, _.grid.h, 100, 200, 100 # green shown if user guesses correctly
    else # otherwise, if clicked note is not target note
      _.state.times_wrong += 1 # increments times user guessed wrong
      queue_click_feedback _, 0, 0, _.grid.w, _.grid.h, 200, 100, 100 # red shown is user guesses wrong
    end
  end
end

# Creates a collection of all of the available notes as symbols
def available_notes
  [:C3, :D3, :E3, :F3, :G3, :A3, :B3, :C4]
end

# Creates buttons for each note, and sets a label (the note's name) and border for each note's button.
def piano_button _, note, position
  _.state.new_entity(:button) do |b| # declares button as new entity
    b.label  =  [460 + 40.mult(position), _.grid.h * 0.4, "#{note}", 0, 1, 0, 0, 0] # label definition
    b.border =  _.state.with_meta([460 + 40.mult(position) - 20, _.grid.h * 0.4 - 32, 40, 40], note) # border definition, text/title; 20 subtracted so label is in center of border
  end
end

# Color of click feedback changes depending on what button was clicked, and whether the guess is right or wrong
# If a button is clicked, the inside of button is purple (see input_mouse method)
# If correct note is clicked, screen turns green
# If incorrect note is clicked, screen turns red (again, see input_mouse method)
def queue_click_feedback _, x, y, w, h, *color
  _.state.click_feedbacks << _.state.new_entity(:click_feedback) do |c| # declares feedback as new entity
    c.solid =  [x, y, w, h, *color, 255] # sets color
  end
end

def tick_instructions args, text, y = 715
  return if args.state.key_event_occurred
  if args.inputs.mouse.click ||
     args.inputs.keyboard.directional_vector ||
     args.inputs.keyboard.key_down.enter ||
     args.inputs.keyboard.key_down.escape
    args.state.key_event_occurred = true
  end

  args.outputs.debug << [0, y - 50, 1280, 60].solid
  args.outputs.debug << [640, y, text, 1, 1, 255, 255, 255].label
  args.outputs.debug << [640, y - 25, "(click to dismiss instructions)" , -2, 1, 255, 255, 255].label
end
