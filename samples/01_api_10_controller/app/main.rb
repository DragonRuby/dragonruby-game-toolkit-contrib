=begin

 APIs listing that haven't been encountered in previous sample apps:

 - args.inputs.controller_one.key_held.KEY: Will check to see if a specific key
   is being held down on the controller.
   If there is more than one controller being used, they can be differentiated by
   using names like controller_one and controller_two.

   For a full listing of buttons, take a look at mygame/documentation/08-controllers.md.

 Reminder:

 - args.state.PROPERTY: The state property on args is a dynamic
   structure. You can define ANY property here with ANY type of
   arbitrary nesting. Properties defined on args.state will be retained
   across frames. If you attempt to access a property that doesn't exist
   on args.state, it will simply return nil (no exception will be thrown).

   In this sample app, args.state.BUTTONS is an array that stores the buttons of the controller.
   The parameters of a button are:
   1. the position (x, y)
   2. the input key held on the controller
   3. the text or name of the button

=end

# This sample app provides a visual demonstration of a standard controller, including
# the placement and function of all buttons.

class ControllerDemo
  attr_accessor :inputs, :state, :outputs

  # Calls the methods necessary for the app to run successfully.
  def tick
    process_inputs
    render
  end

  # Starts with an empty collection of buttons.
  # Adds buttons that are on the controller to the collection.
  def process_inputs
    state.buttons = []

    state.buttons << [100, 500, inputs.controller_one.key_held.l1, "L1"]
    state.buttons << [100, 600, inputs.controller_one.key_held.l2, "L2"]

    state.buttons << [1100, 500, inputs.controller_one.key_held.r1, "R1"]
    state.buttons << [1100, 600, inputs.controller_one.key_held.r2, "R2"]

    state.buttons << [540, 450, inputs.controller_one.key_held.select, "Select"]
    state.buttons << [660, 450, inputs.controller_one.key_held.start, "Start"]

    state.buttons << [200, 300, inputs.controller_one.key_held.left, "Left"]
    state.buttons << [300, 400, inputs.controller_one.key_held.up, "Up"]
    state.buttons << [400, 300, inputs.controller_one.key_held.right, "Right"]
    state.buttons << [300, 200, inputs.controller_one.key_held.down, "Down"]

    state.buttons << [800, 300, inputs.controller_one.key_held.x, "X"]
    state.buttons << [900, 400, inputs.controller_one.key_held.y, "Y"]
    state.buttons << [1000, 300, inputs.controller_one.key_held.a, "A"]
    state.buttons << [900, 200, inputs.controller_one.key_held.b, "B"]

    state.buttons << [450 + inputs.controller_one.left_analog_x_perc * 100,
                      100 + inputs.controller_one.left_analog_y_perc * 100,
                      inputs.controller_one.key_held.l3,
                      "L3"]

    state.buttons << [750 + inputs.controller_one.right_analog_x_perc * 100,
                      100 + inputs.controller_one.right_analog_y_perc * 100,
                      inputs.controller_one.key_held.r3,
                      "R3"]
  end

  # Gives each button a square shape.
  # If the button is being pressed or held (which means it is considered active),
  # the square is filled in. Otherwise, the button simply has a border.
  def render
    state.buttons.each do |x, y, active, text|
      rect = [x, y, 75, 75]

      if active # if button is pressed
        outputs.solids << rect # rect is output as solid (filled in)
      else
        outputs.borders << rect # otherwise, output as border
      end

      # Outputs the text of each button using labels.
      outputs.labels << [x, y + 95, text] # add 95 to place label above button
    end

    outputs.labels << [10, 60, "Left Analog x: #{inputs.controller_one.left_analog_x_raw} (#{inputs.controller_one.left_analog_x_perc * 100}%)"]
    outputs.labels << [10, 30, "Left Analog y: #{inputs.controller_one.left_analog_y_raw} (#{inputs.controller_one.left_analog_y_perc * 100}%)"]
    outputs.labels << [900, 60, "Right Analog x: #{inputs.controller_one.right_analog_x_raw} (#{inputs.controller_one.right_analog_x_perc * 100}%)"]
    outputs.labels << [900, 30, "Right Analog y: #{inputs.controller_one.right_analog_y_raw} (#{inputs.controller_one.right_analog_y_perc * 100}%)"]
  end
end

$controller_demo = ControllerDemo.new

def tick args
  tick_instructions args, "Sample app shows how controller input is handled. You'll need to connect a USB controller."
  $controller_demo.inputs = args.inputs
  $controller_demo.state = args.state
  $controller_demo.outputs = args.outputs
  $controller_demo.tick
end

# Resets the app.
def r
  $gtk.reset
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
