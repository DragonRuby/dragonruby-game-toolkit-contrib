def tick args
  args.outputs.background_color = [30, 30, 30]

  # track the max_hp, current_hp, and hp_perc (this is what we'll use to render remaining health)
  args.state.max_hp ||= 100
  args.state.current_hp ||= 100
  args.state.hp_perc ||= 1.0

  # every frame, lerp the hp_perc to current_hp / max_hp
  args.state.hp_perc = args.state.hp_perc.lerp(args.state.current_hp / args.state.max_hp, 0.1)

  # if j is pressed, or mouse is clicked, decrease the current hp (reset it if hp hits 0)
  if args.inputs.keyboard.key_down.enter || args.inputs.mouse.click
    if args.state.current_hp == 0
      args.state.current_hp = args.state.max_hp
    else
      args.state.current_hp -= 10
    end
  end

  args.outputs.labels << { x: 640,
                           y: 360 - 32,
                           text: "#{args.state.current_hp} / #{args.state.max_hp}",
                           anchor_x: 0.5,
                           anchor_y: 0.5,
                           r: 255, g: 255, b: 255 }

  # outer black border of the progress bar
  args.outputs.sprites << { x: 640 - 64,
                            y: 360,
                            w: 128,
                            h: 32,
                            path: :solid,
                            r: 0,
                            g: 0,
                            b: 0,
                            anchor_y: 0.5 }

  # inner white area of the progress bar
  args.outputs.sprites << { x: 640 - 62,
                            y: 360,
                            w: 124,
                            h: 28,
                            path: :solid,
                            r: 255,
                            g: 255,
                            b: 255,
                            anchor_y: 0.5 }

  # current health
  args.outputs.sprites << { x: 640 - 62,
                            y: 360,
                            w: 124 * args.state.hp_perc,
                            h: 28,
                            path: :solid,
                            r: 0,
                            g: 128,
                            b: 128,
                            anchor_y: 0.5 }
end
