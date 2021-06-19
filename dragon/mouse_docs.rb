# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# mouse_docs.rb has been released under MIT (*only this file*).

module MouseDocs
  def docs_class
<<-S
* DOCS: ~GTK::Mouse~

The mouse is accessible via ~args.inputs.mouse~:

#+begin_src ruby
  def tick args
    # Rendering a label that shows the mouse's x and y position (via args.inputs.mouse).
    args.outputs.labels << [
      10,
      710,
      "The mouse's position is: \#{args.inputs.mouse.x} \#{args.inputs.mouse.y}."
    ]
  end
#+end_src

The mouse has the following properties.

- ~args.inputs.mouse.x~: Returns the x position of the mouse.
- ~args.inputs.mouse.y~: Returns the y position of the mouse.
- ~args.inputs.mouse.moved~: Returns true if the mouse moved during the tick.
- ~args.inputs.mouse.moved_at~: Returns the tick_count (~args.state.tick_count~) that the mouse was moved at. This property will be ~nil~ if the mouse didn't move.
- ~args.inputs.mouse.global_moved_at~: Returns the global tick_count (~Kernel.global_tick_count~) that the mouse was moved at. This property will be ~nil~ if the mouse didn't move.
- ~args.inputs.mouse.click~: Returns a ~GTK::MousePoint~ for that specific frame (~args.state.tick_count~) if the mouse button was pressed.
- ~args.inputs.mouse.previous_click~: Returns a ~GTK::MousePoint~ for the previous frame (~args.state.tick_count - 1~) if the mouse button was pressed.
- ~args.inputs.mouse.up~: Returns true if for that specific frame (~args.state.tick_count~) if the mouse button was released.
- ~args.inputs.mouse.point~ | ~args.inputs.mouse.position~: Returns an ~Array~ which contains the ~x~ and ~y~ position of the mouse.
- ~args.inputs.mouse.has_focus~: Returns true if the game window has the mouse's focus.
- ~args.inputs.mouse.wheel~: Returns an ~GTK::OpenEntity~ that contains an ~x~ and ~y~ property which represents how much the wheel has moved. If the wheel has not moved within the tick, this property will be ~nil~.
- ~args.inputs.mouse.button_left~: Returns true if the left mouse button is down.
- ~args.inputs.mouse.button_right~: Returns true if the right mouse button is down.
- ~args.inputs.mouse.button_middle~: Returns true if the middle mouse button is down.
- ~args.inputs.mouse.button_bits~: Gives the bits for each mouse button and its current state.

* DOCS: ~GTK::MousePoint~

The ~GTK::MousePoint~ has the following properties.

- ~x~: Integer representing the mouse's x.
- ~y~: Integer representing the mouse's y.
- ~point~: Array with the ~x~ and ~y~ values.
- ~w~: Width of the point that always returns ~0~ (included so that it can seamlessly work with ~GTK::Geometry~ functions).
- ~h~: Height of the point that always returns ~0~ (included so that it can seamlessly work with ~GTK::Geometry~ functions).
- ~left~: This value is the same as ~x~ (included so that it can seamlessly work with ~GTK::Geometry~ functions).
- ~right~: This value is the same as ~x~ (included so that it can seamlessly work with ~GTK::Geometry~ functions).
- ~top~: This value is the same as ~y~ (included so that it can seamlessly work with ~GTK::Geometry~ functions).
- ~bottom~: This value is the same as ~y~ (included so that it can seamlessly work with ~GTK::Geometry~ functions).
- ~created_at~: The tick (~args.state.tick_count~) that this structure was created.
- ~global_created_at~: The global tick (~Kernel.global_tick_count~) that this structure was created.

S
  end
end

class GTK::Mouse
  extend Docs
  extend MouseDocs
end
