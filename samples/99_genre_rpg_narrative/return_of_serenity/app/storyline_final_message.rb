def final_message_sad args
  {
    fade: 60,
    background: 'sprites/inside-home.png',
    player: [34, 35],
    storylines: [
      [34, 34, 4, 4, "Another-- sleepless-- night..."],
    ],
    scenes: [
      [32, -1, 8, 3, :final_message_observatory]
    ]
  }
end

def final_message_happy args
  {
    fade: 60,
    background: 'sprites/inside-home.png',
    player: [34, 35],
    storylines: [
      [34, 34, 4, 4, "Oh man, I slept like rock!"],
    ],
    scenes: [
      [32, -1, 8, 3, :final_message_observatory]
    ]
  }
end

def final_message_side_of_home args
  {
    fade: 60,
    background: 'sprites/side-of-home.png',
    player: [16, 13],
    scenes: [
      [52, 24, 11, 5, :final_message_mountain_pass],
    ],
    render_override: :blinking_light_side_of_home_render
  }
end

def final_message_mountain_pass args
  {
    background: 'sprites/mountain-pass-zoomed-out.png',
    player: [4, 4],
    scenes: [
      [18, 47, 5, 5, :final_message_path_to_observatory],
    ],
    storylines: [
      [18, 13, 5, 5, "Hnnnnnnnggg. My legs-- are still sore- from yesterday."]
    ],
    render_override: :blinking_light_mountain_pass_render
  }
end

def final_message_path_to_observatory args
  {
    background: 'sprites/path-to-observatory.png',
    player: [60, 4],
    scenes: [
      [0, 26, 5, 5, :final_message_observatory]
    ],
    storylines: [
      [22, 20, 10, 10, "This spot--, on the mountain, right here, it's-- perfect. This- is where- I'll-- yeet-- the person-- who is playing-- this- prank- on me."]
    ],
    render_override: :blinking_light_path_to_observatory_render
  }
end

def final_message_observatory args
  if args.state.scene_history.include? :replied_with_whole_truth
    return {
      background: 'sprites/inside-observatory.png',
      fade: 60,
      player: [51, 12],
      storylines: [
        [50, 10, 4, 4, "Here-- we- go..."]
      ],
      scenes: [
        [30, 18, 5, 12, :final_message_inside_mainframe]
      ],
      render_override: :blinking_light_inside_observatory_render
    }
  else
    return {
      background: 'sprites/inside-observatory.png',
      fade: 60,
      player: [51, 12],
      storylines: [
        [50, 10, 4, 4, "I feel like I'm-- walking-- on sunshine!"]
      ],
      scenes: [
        [30, 18, 5, 12, :final_message_inside_mainframe]
      ],
      render_override: :blinking_light_inside_observatory_render
    }
  end
end

def final_message_inside_mainframe args
  {
    player: [32, 4],
    background: 'sprites/mainframe.png',
    fade: 60,
    scenes: [[45, 45,  4, 4, :final_message_check_ship_status]]
  }
end

def final_message_check_ship_status args
  {
    background: 'sprites/mainframe.png',
    storylines: [
      [45, 45, 4, 4, (final_message_current args)],
    ],
    scenes: [
      [*hotspot_top, :final_message_ship_status],
    ]
  }
end

def final_message_ship_status args
  {
    background: 'sprites/serenity.png',
    fade: 60,
    player: [30, 10],
    scenes: [
      [30, 50, 4, 4, :final_message_ship_status_reviewed]
    ],
    storylines: [
      [30,  8, 4, 4, "Let me make- sure- everything--- looks good. It'll-- give me peace- of mind."],
      *final_message_ship_status_shared(args)
    ]
  }
end

def final_message_ship_status_reviewed args
  {
    background: 'sprites/serenity.png',
    fade: 60,
    scenes: [
      [*hotspot_bottom, :final_message_summary]
    ],
    storylines: [
      [0, 62, 62, 3, "Whew. Everyone-- is in their- chambers. The engines-- are roaring-- and Serenity-- is coming-- home."],
    ]
  }
end

def final_message_ship_status_shared args
  [
    *ship_control_hotspot( 0, 50,
                           "Stasis-- Chambers--: Online, All chambers-- are powered. Battery--- Allocation---: 3--- of-- 3--.",
                           "Matthew's--- Chamber--: OCCUPIED----",
                           "Aanka's--- Chamber--: OCCUPIED----",
                           "Sasha's--- Chamber--: OCCUPIED----"),
    *ship_control_hotspot(12, 35,
                          "Life- Support--: Not-- Needed---",
                          "O2--- Production---: OFF---",
                          "CO2--- Scrubbers---: OFF---",
                          "H2O--- Production---: OFF---"),
    *ship_control_hotspot(24, 20,
                          "Navigation: Offline---",
                          "Sensor: OFF---",
                          "Heads- Up- Display: DAMAGED---",
                          "Arithmetic--- Unit: DAMAGED----"),
    *ship_control_hotspot(36, 35,
                          "COMM: Underpowered----",
                          "Text: ON---",
                          "Audio: SEGFAULT---",
                          "Video: DAMAGED---"),
    *ship_control_hotspot(48, 50,
                          "Engine: Online, Coordinates--- Set- for Earth. Battery--- Allocation---: 3--- of-- 3---",
                          "Engine I: ON---",
                          "Engine II: ON---",
                          "Engine III: ON---")
  ]
end

def final_message_last_reply args
  if args.state.scene_history.include? :replied_with_whole_truth
    return "Buffer--: #{anka_reply_whole_truth.quote}"
  else
    return "Buffer--: #{anka_reply_half_truth.quote}"
  end
end

def final_message_current args
  if args.state.scene_history.include? :replied_with_whole_truth
    return "Hey... It's-- me Sasha. Aanka-- is trying-- her best to comfort-- Matthew. This- is the first- time- I've-- ever-- seen-- Matthew-- cry. We'll-- probably-- be in stasis-- by the time you get this message--. Thank- you- again-- for all your help. I look forward-- to meeting-- you in person."
  else
    return "Hey! It's-- me Sasha! LOL! Aanka-- and Matthew-- are dancing-- around-- like- goofballs--! They- are both- so adorable! Only-- this- tiny-- little-- genius-- can make-- a battle-- hardened-- general--- put- on a tiara-- and dance- around-- like a fairy-- princess-- XD------ Anyways, we are heading-- back into-- the chambers--. I hope our welcome-- home- parade-- has fireworks!"
  end
end

def final_message_summary args
  if args.state.scene_history.include? :replied_with_whole_truth
    return {
      background: 'sprites/inside-observatory.png',
      fade: 60,
      player: [31, 11],
      scenes: [[60, 0, 4, 32, :final_decision_side_of_home]],
      storylines: [
        [30, 10, 5, 4, "I can't-- imagine-- what they are feeling-- right now. But at least- they- know everything---, and we can- concentrate-- on rebuilding--- this world-- right- off the bat. I can't-- wait to see the future-- they'll-- help- build."],
      ]
    }
  else
    return {
      background: 'sprites/inside-observatory.png',
      fade: 60,
      player: [31, 11],
      scenes: [[60, 0, 4, 32, :final_decision_side_of_home]],
      storylines: [
        [30, 10, 5, 4, "They all sounded-- so happy. I know- they'll-- be in for a tough- dose- of reality--- when they- arrive. But- at least- they'll-- be around-- all- of us. We'll-- help them- cope."],
      ]
    }
  end
end
