=begin

 APIs listing that haven't been encountered in previous sample apps:

 - args.current_controller.key_held.KEY: Will check to see if a specific key
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
    state.target  ||= :controller_one
    state.buttons = []

    if inputs.keyboard.key_down.tab
      if state.target == :controller_one
        state.target = :controller_two
      elsif state.target == :controller_two
        state.target = :controller_three
      elsif state.target == :controller_three
        state.target = :controller_four
      elsif state.target == :controller_four
        state.target = :controller_one
      end
    end

    state.buttons << { x: 100,  y: 500, active: current_controller.key_held.l1, text: "L1"}
    state.buttons << { x: 100,  y: 600, active: current_controller.key_held.l2, text: "L2"}
    state.buttons << { x: 1100, y: 500, active: current_controller.key_held.r1, text: "R1"}
    state.buttons << { x: 1100, y: 600, active: current_controller.key_held.r2, text: "R2"}
    state.buttons << { x: 540,  y: 450, active: current_controller.key_held.select, text: "Select"}
    state.buttons << { x: 660,  y: 450, active: current_controller.key_held.start, text: "Start"}
    state.buttons << { x: 200,  y: 300, active: current_controller.key_held.left, text: "Left"}
    state.buttons << { x: 300,  y: 400, active: current_controller.key_held.up, text: "Up"}
    state.buttons << { x: 400,  y: 300, active: current_controller.key_held.right, text: "Right"}
    state.buttons << { x: 300,  y: 200, active: current_controller.key_held.down, text: "Down"}
    state.buttons << { x: 800,  y: 300, active: current_controller.key_held.x, text: "X"}
    state.buttons << { x: 900,  y: 400, active: current_controller.key_held.y, text: "Y"}
    state.buttons << { x: 1000, y: 300, active: current_controller.key_held.a, text: "A"}
    state.buttons << { x: 900,  y: 200, active: current_controller.key_held.b, text: "B"}
    state.buttons << { x: 450 + current_controller.left_analog_x_perc * 100,
                       y: 100 + current_controller.left_analog_y_perc * 100,
                       active: current_controller.key_held.l3,
                       text: "L3" }
    state.buttons << { x: 750 + current_controller.right_analog_x_perc * 100,
                       y: 100 + current_controller.right_analog_y_perc * 100,
                       active: current_controller.key_held.r3,
                       text: "R3" }
  end

  # Gives each button a square shape.
  # If the button is being pressed or held (which means it is considered active),
  # the square is filled in. Otherwise, the button simply has a border.
  def render
    state.buttons.each do |b|
      rect = { x: b.x, y: b.y, w: 75, h: 75 }

      if b.active # if button is pressed
        outputs.solids << rect # rect is output as solid (filled in)
      else
        outputs.borders << rect # otherwise, output as border
      end

      # Outputs the text of each button using labels.
      outputs.labels << { x: b.x, y: b.y + 95, text: b.text } # add 95 to place label above button
    end

    outputs.labels << { x:  10, y: 60, text: "Left Analog x: #{current_controller.left_analog_x_raw} (#{current_controller.left_analog_x_perc * 100}%)" }
    outputs.labels << { x:  10, y: 30, text: "Left Analog y: #{current_controller.left_analog_y_raw} (#{current_controller.left_analog_y_perc * 100}%)" }
    outputs.labels << { x: 1270, y: 60, text: "Right Analog x: #{current_controller.right_analog_x_raw} (#{current_controller.right_analog_x_perc * 100}%)", alignment_enum: 2 }
    outputs.labels << { x: 1270, y: 30, text: "Right Analog y: #{current_controller.right_analog_y_raw} (#{current_controller.right_analog_y_perc * 100}%)" , alignment_enum: 2 }

    outputs.labels << { x: 640, y: 60, text: "Target: #{state.target} (press tab to go to next controller)", alignment_enum: 1 }
    outputs.labels << { x: 640, y: 30, text: "Connected: #{current_controller.connected}", alignment_enum: 1 }
  end

  def current_controller
    if state.target == :controller_one
      return inputs.controller_one
    elsif state.target == :controller_two
      return inputs.controller_two
    elsif state.target == :controller_three
      return inputs.controller_three
    elsif state.target == :controller_four
      return inputs.controller_four
    end
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
