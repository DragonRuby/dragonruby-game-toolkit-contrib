def tick args
  # initialize the scene to scene 1
  args.state.current_scene ||= :title_scene
  # capture the current scene to verify it didn't change through
  # the duration of tick
  current_scene = args.state.current_scene

  # tick whichever scene is current
  case current_scene
  when :title_scene
    tick_title_scene args
  when :game_scene
    tick_game_scene args
  when :game_over_scene
    tick_game_over_scene args
  end

  # make sure that the current_scene flag wasn't set mid tick
  if args.state.current_scene != current_scene
    raise "Scene was changed incorrectly. Set args.state.next_scene to change scenes."
  end

  # if next scene was set/requested, then transition the current scene to the next scene
  if args.state.next_scene
    args.state.current_scene = args.state.next_scene
    args.state.next_scene = nil
  end
end

def tick_title_scene args
  args.outputs.labels << { x: 640,
                           y: 360,
                           text: "Title Scene (click to go to game)",
                           alignment_enum: 1 }

  if args.inputs.mouse.click
    args.state.next_scene = :game_scene
  end
end

def tick_game_scene args
  args.outputs.labels << { x: 640,
                           y: 360,
                           text: "Game Scene (click to go to game over)",
                           alignment_enum: 1 }

  if args.inputs.mouse.click
    args.state.next_scene = :game_over_scene
  end
end

def tick_game_over_scene args
  args.outputs.labels << { x: 640,
                           y: 360,
                           text: "Game Over Scene (click to go to title)",
                           alignment_enum: 1 }

  if args.inputs.mouse.click
    args.state.next_scene = :title_scene
  end
end
