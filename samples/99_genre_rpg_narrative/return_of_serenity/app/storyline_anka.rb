def anka_inside_room args
  {
    background: 'sprites/inside-home.png',
    player: [34, 35],
    storylines: [
      [34, 34, 4, 4, "Ahhhh!!! Oh god, it was just- a nightmare."],
    ],
    scenes: [
      [32, -1, 8, 3, :anka_observatory]
    ]
  }
end

def anka_observatory args
  {
    background: 'sprites/inside-observatory.png',
    fade: 60,
    player: [51, 12],
    storylines: [
      [50, 10, 4, 4,   "Breathe, Hiro. Just see what's there... everything--- will- be okay."]
    ],
    scenes: [
      [30, 18, 5, 12, :anka_inside_mainframe]
    ],
    render_override: :blinking_light_inside_observatory_render
  }
end

def anka_inside_mainframe args
  {
    player: [32, 4],
    background: 'sprites/mainframe.png',
    fade: 60,
    storylines: [
      [22, 45, 17, 4, (anka_last_reply args)],
      [45, 45,  4, 4, (anka_current_reply args)],
    ],
    scenes: [
      [*hotspot_top_right, :reply_to_anka]
    ]
  }
end

def reply_to_anka args
  decision_graph anka_current_reply(args),
                 "Matthew's-- wife is doing-- well. What's-- even-- better-- is that he's-- a dad, and he didn't-- even-- know it. Should- I- leave- out the part about-- the crew- being-- in hibernation-- for 20-- years? They- should- enter-- statis-- on a high- note... Right?",
                 [:replied_with_whole_truth, "Whole-- Truth--", anka_reply_whole_truth],
                 [:replied_with_half_truth, "Half-- Truth--", anka_reply_half_truth]
end

def anka_last_reply args
  if args.state.scene_history.include? :replied_to_serenity_alive_firmly
    return "Buffer--: #{serenity_alive_firm_reply.quote}"
  else
    return "Buffer--: #{serenity_alive_sugarcoated_reply.quote}"
  end
end

def anka_reply_whole_truth
  "Matthew's wife is doing-- very-- well. In fact, she was pregnant. Matthew-- is a dad. He has a son. But, I need- all-- of-- you-- to brace-- yourselves. You've-- been in statis-- for 20 years. A lot has changed. Most of Earth's-- population--- didn't-- survive. Tell- Matthew-- that I'm-- sorry he didn't-- get to see- his- son grow- up."
end

def anka_reply_half_truth
  "Matthew's--- wife- is doing-- very-- well. In fact, she was pregnant. Matthew is a dad! It's a boy! Tell- Matthew-- congrats-- for me. Hope-- to see- all of you- soon."
end

def replied_with_whole_truth args
  {
    background: 'sprites/inside-observatory.png',
    fade: 60,
    player: [32, 21],
    scenes: [[60, 0, 4, 32, :replied_to_anka_back_home]],
    storylines: [
      [30, 18, 5, 12, "Buffer-- has been set to: #{anka_reply_whole_truth.quote}"],
      [30, 10, 5, 4, "I- hope- I- did the right- thing- by laying-- it all- out- there."],
    ]
  }
end

def replied_with_half_truth args
  {
    background: 'sprites/inside-observatory.png',
    fade: 60,
    player: [32, 21],
    scenes: [[60, 0, 4, 32, :replied_to_anka_back_home]],
    storylines: [
      [30, 18, 5, 12, "Buffer-- has been set to: #{anka_reply_half_truth.quote}"],
      [30, 10, 5, 4, "I- hope- I- did the right- thing- by not giving-- them- the whole- truth."],
    ]
  }
end

def anka_current_reply args
  if args.state.scene_history.include? :replied_to_serenity_alive_firmly
    return "Hello. This is, Aanka. Sasha-- is still- trying-- to gather-- her wits about-- her, given- the gravity--- of your- last- reply. Thank- you- for being-- honest, and thank- you- for the help- with the ship- diagnostics. I was able-- to retrieve-- all of the navigation--- information---- after-- the battery--- swap. We- are ready-- to head back to Earth. Before-- we go- back- into-- statis, Matthew--- wanted-- to know- how his- wife- is doing. Please- reply-- as soon- as you can. He's-- not going-- to get- into-- the statis-- chamber-- until-- he knows- his wife is okay."
  else
    return "Hello. This is, Aanka. Thank- you for the help- with the ship's-- diagnostics. I was able-- to retrieve-- all of the navigation--- information--- after-- the battery-- swap. I- know-- that- you didn't-- tell- the whole truth- about-- how far we are from- Earth. Don't-- worry. I understand-- why you did it. We- are ready-- to head back to Earth. Before-- we go- back- into-- statis, Matthew--- wanted-- to know- how his- wife- is doing. Please- reply-- as soon- as you can. He's-- not going-- to get- into-- the statis-- chamber-- until-- he knows- his wife is okay."
  end
end

def replied_to_anka_back_home args
  if args.state.scene_history.include? :replied_with_whole_truth
    return {
      fade: 60,
      background: 'sprites/inside-home.png',
      player: [34, 4],
      storylines: [
        [34, 4, 4, 4, "I- hope-- this pit in my stomach-- is gone-- by tomorrow---."],
      ],
      scenes: [
        [30, 38, 12, 13, :final_message_sad],
      ]
    }
  else
    return {
      fade: 60,
      background: 'sprites/inside-home.png',
      player: [34, 4],
      storylines: [
        [34, 4, 4, 4, "I- get the feeling-- I'm going-- to sleep real well tonight--."],
      ],
      scenes: [
        [30, 38, 12, 13, :final_message_happy],
      ]
    }
  end
end
