def boot args
  # initialize args.state to an empty hash on boot
  args.state = {}
end

def tick args
  defaults args
  calc args
  render args
end

def defaults args
  # animation duration of the checkbox (15 frames/quarter of a second)
  args.state.checkbox_animation_duration ||= 15

  # use layout apis to position check boxes
  # set the time the checkbox was changed to "the past" so it shows up immediately on load
  args.state.checkboxes ||= [
    Layout.rect(row: 0, col: 0, w: 1, h: 1)
          .merge(id: :option_1, text: "Option 1", checked: false, changed_at: -args.state.checkbox_animation_duration),
    Layout.rect(row: 1, col: 0, w: 1, h: 1)
          .merge(id: :option_2, text: "Option 2", checked: false, changed_at: -args.state.checkbox_animation_duration),
    Layout.rect(row: 2, col: 0, w: 1, h: 1)
          .merge(id: :option_3, text: "Option 3", checked: false, changed_at: -args.state.checkbox_animation_duration),
    Layout.rect(row: 3, col: 0, w: 1, h: 1)
          .merge(id: :option_4, text: "Option 4", checked: false, changed_at: -args.state.checkbox_animation_duration),
  ]

  # if it's the first tick, then load checkbox state from save file
  if Kernel.tick_count == 0
    load_checkbox_state args.state.checkboxes
  end
end

def calc args
  return if !args.inputs.mouse.click

  # see if any checkboxes were checked
  clicked_checkbox = args.state.checkboxes.find do |checkbox|
    Geometry.inside_rect? args.inputs.mouse, checkbox
  end

  # if no checkboxes were clicked, return
  return if !clicked_checkbox

  # toggle the checkbox's checked state and mark when it was checked
  clicked_checkbox.checked = !clicked_checkbox.checked
  clicked_checkbox.changed_at = Kernel.tick_count

  # save checkbox state to file
  save_checkbox_state args.state.checkboxes
end

def render args
  # render checkboxes using the checkbox_prefab function
  args.outputs.primitives << args.state.checkboxes.map do |checkbox|
    checkbox_prefab checkbox, args.state.checkbox_animation_duration
  end
end

def checkbox_prefab checkbox, animation_duration
  # this is the visuals for the checkbox

  # compute the location of the label
  label = {
    x: checkbox.x + checkbox.w + 8,
    y: checkbox.center.y,
    text: checkbox.text,
    anchor_x: 0.0,
    anchor_y: 0.5,
    size_px: 22
  }

  # this represents the checkbox area
  border = {
    x: checkbox.x, y: checkbox.y, w: checkbox.w, h: checkbox.h,
    r: 200, g: 200, b: 200,
    path: :solid
  }

  # determine the check state fade in/fade out percentage
  # use the checkbox.changed_at to determine the percentage
  animation_percentage = if checkbox.checked
                           Easing.smooth_stop(start_at: checkbox.changed_at,
                                              duration: animation_duration,
                                              tick_count: Kernel.tick_count,
                                              power: 4,
                                              flip: false)
                         else
                           Easing.smooth_stop(start_at: checkbox.changed_at,
                                              duration: animation_duration,
                                              tick_count: Kernel.tick_count,
                                              power: 4,
                                              flip: true)
                         end

  # using the percentage that was calculated, and
  # render a solid that represents the checkbox's "checked" indicator
  indicator = {
    x: checkbox.center.x,
    y: checkbox.center.y,
    w: (checkbox.w / 2) * animation_percentage,
    h: (checkbox.h / 2) * animation_percentage,
    anchor_x: 0.5,
    anchor_y: 0.5,
    path: :solid,
    r: 0, g: 0, b: 0,
    a: animation_percentage * 255
  }

  # render the labe, border, and indicator
  [
    label,
    border,
    indicator,
  ]
end

def save_checkbox_state checkboxes
  # create the save data in the format of id,checked
  # eg:
  #   option_1,true
  #   option_2,false
  #   option_3,false
  #   option_4,false
  content = checkboxes.map do |c|
    "#{c.id},#{c.checked}"
  end.join "\n"

  # write the contents to data/checkbox-state.txt
  GTK.write_file "data/checkbox-state.txt", content
end

def load_checkbox_state checkboxes
  # read the save file
  content = GTK.read_file "data/checkbox-state.txt"

  # if it doesn't exist then return
  return if !content

  # eg:
  #   option_1,true
  #   option_2,false
  #   option_3,false
  #   option_4,false
  # becomes:
  #   results = {
  #     option_1: true,
  #     option_2: false,
  #     option_3: false,
  #     option_4: false,
  #   }
  results = { }

  # each line has the id of the checkbox, and its value
  content.each_line do |l|
    # get the tokens split on commas for the line
    tokens = l.strip.split(",")

    # the first token is the id of the checkbox
    id = tokens[0].to_sym

    # the second value is the check state
    checked = tokens[1] == "true"

    # store values in the results lookup
    results[id] = checked
  end

  # after the results have been parsed from the file,
  # go through the checkboxes and set their checked value to
  # what was found in the file
  checkboxes.each do |c|
    c.checked = results[c.id]
  end
end
