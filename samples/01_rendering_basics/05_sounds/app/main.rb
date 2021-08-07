=begin

 APIs Listing that haven't been encountered in previous sample apps:

 - sample: Chooses random element from array.
   In this sample app, the target note is set by taking a sample from the collection
   of available notes.

 Reminders:

 - String interpolation: Uses #{} syntax; everything between the #{ and the } is evaluated
   as Ruby code, and the placeholder is replaced with its corresponding value or result.

 - args.outputs.labels: An array. The values generate a label.
   The parameters are [X, Y, TEXT, SIZE, ALIGNMENT, RED, GREEN, BLUE, ALPHA, FONT STYLE]
   For more information about labels, go to mygame/documentation/02-labels.md.
=end

# This sample app allows users to test their musical skills by matching the piano sound that plays in each
# level to the correct note.

# Runs all the methods necessary for the game to function properly.
def tick args
  args.outputs.labels << [640, 360, "Click anywhere to play a random sound.", 0, 1]
  args.state.notes ||= [:C3, :D3, :E3, :F3, :G3, :A3, :B3, :C4]

  if args.inputs.mouse.click
    # Play a sound by adding a string to args.outputs.sounds
    args.outputs.sounds << "sounds/#{args.state.notes.sample}.wav" # sound of target note is output
  end
end
