=begin

 APIs Listing that haven't been encountered in previous sample apps:

 - sample: Chooses random element from array.
   In this sample app, the target note is set by taking a sample from the collection
   of available notes.

 - String interpolation: Uses #{} syntax; everything between the #{ and the } is evaluated
   as Ruby code, and the placeholder is replaced with its corresponding value or result.

 - Mouse click is provided through args.inputs.mouse.click (or args.inputs.mouse.key_down.left)

 - Mouse right click is provided through args.inputs.mouse.key_down.right
=end
def tick args
  args.outputs.labels << { x: 640, y: 360, text: "Click anywhere to play a random sound.", anchor_x: 0.5, anchor_y: 0.5 }
  args.outputs.labels << { x: 640, y: 360, text: "Right Click anywhere to play a random sound at 10% volume.", anchor_x: 0.5, anchor_y: 1.5 }
  args.state.notes ||= [:c3, :d3, :e3, :f3, :g3, :a3, :b3, :c4]

  if args.inputs.mouse.click
    # Play a sound by adding a string to args.outputs.sounds
    args.outputs.sounds << "sounds/#{args.state.notes.sample}.wav" # sound of target note is output
  elsif args.inputs.mouse.key_down.right
    # specifying volume of sound
    args.outputs.sounds << { path: "sounds/#{args.state.notes.sample}.wav", gain: 0.1 }
  end
end
