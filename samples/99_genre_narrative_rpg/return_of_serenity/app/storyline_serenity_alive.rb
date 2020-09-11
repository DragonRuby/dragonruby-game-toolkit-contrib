def serenity_alive_side_of_home args
  {
    fade: 60,
    background: 'sprites/side-of-home.png',
    player: [16, 13],
    scenes: [
      [52, 24, 11, 5, :serenity_alive_mountain_pass],
    ],
    render_override: :blinking_light_side_of_home_render
  }
end

def serenity_alive_mountain_pass args
  {
    background: 'sprites/mountain-pass-zoomed-out.png',
    player: [4, 4],
    scenes: [
      [18, 47, 5, 5, :serenity_alive_path_to_observatory],
    ],
    storylines: [
      [18, 13, 5, 5, "Hnnnnnnnggg. My legs-- are still sore- from yesterday."]
    ],
    render_override: :blinking_light_mountain_pass_render
  }
end

def serenity_alive_path_to_observatory args
  {
    background: 'sprites/path-to-observatory.png',
    player: [60, 4],
    scenes: [
      [0, 26, 5, 5, :serenity_alive_observatory]
    ],
    storylines: [
      [22, 20, 10, 10, "This spot--, on the mountain, right here, it's-- perfect. This- is where- I'll-- yeet-- the person-- who is playing-- this- prank- on me."]
    ],
    render_override: :blinking_light_path_to_observatory_render
  }
end

def serenity_alive_observatory args
  {
    background: 'sprites/observatory.png',
    player: [60, 2],
    scenes: [
      [28, 39, 4, 10, :serenity_alive_inside_observatory]
    ],
    render_override: :blinking_light_observatory_render
  }
end

def serenity_alive_inside_observatory args
  {
    background: 'sprites/inside-observatory.png',
    player: [60, 2],
    storylines: [],
    scenes: [
      [30, 18, 5, 12, :serenity_alive_inside_mainframe]
    ],
    render_override: :blinking_light_inside_observatory_render
  }
end

def serenity_alive_inside_mainframe args
  {
    background: 'sprites/mainframe.png',
    fade: 60,
    player: [30, 4],
    scenes: [
      [*hotspot_top, :serenity_alive_ship_status],
    ],
    storylines: [
      [22, 45, 17, 4, (serenity_alive_last_reply args)],
      [45, 45,  4, 4, (serenity_alive_current_message args)],
    ]
  }
end

def serenity_alive_ship_status args
  {
    background: 'sprites/serenity.png',
    fade: 60,
    player: [30, 10],
    scenes: [
      [30, 50, 4, 4, :serenity_alive_ship_status_reviewed]
    ],
    storylines: [
      [30,  8, 4, 4, "Serenity? THE--- Mission-- Serenity?! How is that possible? They- are supposed-- to be dead."],
      [30, 10, 4, 4, "I... can't-- believe-- it. I- can access-- Serenity's-- computer? I- guess my \"superpower----\" isn't limited-- by proximity-- to- a machine--."],
      *serenity_alive_shared_ship_status(args)
    ]
  }
end

def serenity_alive_ship_status_reviewed args
  {
    background: 'sprites/serenity.png',
    fade: 60,
    scenes: [
      [*hotspot_bottom, :serenity_alive_time_to_reply]
    ],
    storylines: [
      [0, 62, 62, 3, "Okay. Reviewing-- everything--, it looks- like- I- can- take- the batteries--- from the Stasis--- Chambers--- and- Engine--- to keep- the crew-- alive-- and-- their-- location--- pinpointed---."],
    ]
  }
end

def serenity_alive_time_to_reply args
  decision_graph serenity_alive_current_message(args),
                  "Okay... time to deliver the bad news...",
                  [:replied_to_serenity_alive_firmly, "Firm-- Reply", serenity_alive_firm_reply],
                  [:replied_to_serenity_alive_kindly, "Sugar-- Coated---- Reply", serenity_alive_sugarcoated_reply]
end

def serenity_alive_shared_ship_status args
  [
    *ship_control_hotspot( 0, 50,
                           "Stasis-- Chambers--: Online, All chambers-- are powered. Battery--- Allocation---: 3--- of-- 3--, Hmmm. They don't-- need this to be powered-- right- now. Everyone-- is awake.",
                           nil,
                           nil,
                           nil),
    *ship_control_hotspot(12, 35,
                          "Life- Support--: Offline, Unable--- to- Sustain-- Life. Battery--- Allocation---: 0--- of-- 3---, Okay. That is definitely---- not a good thing.",
                          nil,
                          nil,
                          nil),
    *ship_control_hotspot(24, 20,
                          "Navigation: Offline, Unable--- to- Calculate--- Location. Battery--- Allocation---: 0--- of-- 3---, Whelp. No wonder-- Sasha-- can't-- get- any-- readings. Their- Navigation--- is completely--- offline.",
                          nil,
                          nil,
                          nil),
    *ship_control_hotspot(36, 35,
                          "COMM: Underpowered----, Limited--- to- Text-- Based-- COMM. Battery--- Allocation---: 1--- of-- 3---, It's-- lucky- that- their- COMM---- system was able to survive-- twenty-- years--. Just- barely-- it seems.",
                          nil,
                          nil,
                          nil),
    *ship_control_hotspot(48, 50,
                          "Engine: Online, Full- Control-- Available. Battery--- Allocation---: 3--- of-- 3---, Hmmm. No point of having an engine-- online--, if you don't- know- where you're-- going.",
                          nil,
                          nil,
                          nil)
  ]
end

def serenity_alive_firm_reply
  "Serenity, you are at a distance-- farther-- than- Neptune. All- of the ship's-- systems-- are failing. Please- move the batteries---- from- the Stasis-- Chambers-- over- to- Life-- Support--. I also-- need- you to move-- the batteries---- from- the Engines--- to your Navigation---- System."
end

def serenity_alive_sugarcoated_reply
  "So... you- are- a teeny--- tiny--- bit--- farther-- from Earth- than you think. And you have a teeny--- tiny--- problem-- with your ship. Please-- move the batteries--- from the Stasis--- Chambers--- over to Life--- Support---. I also need you to move the batteries--- from the Engines--- to your- Navigation--- System. Don't-- worry-- Sasha. I'll-- get y'all-- home."
end

def replied_to_serenity_alive_firmly args
  {
    background: 'sprites/inside-observatory.png',
    fade: 60,
    player: [32, 21],
    scenes: [
      [*hotspot_bottom_right, :serenity_alive_path_from_observatory]
    ],
    storylines: [
      [30, 18, 5, 12, "Buffer-- has been set to: #{serenity_alive_firm_reply.quote}"],
      *serenity_alive_reply_completed_shared_hotspots(args),
    ]
  }
end

def replied_to_serenity_alive_kindly args
  {
    background: 'sprites/inside-observatory.png',
    fade: 60,
    player: [32, 21],
    scenes: [
      [*hotspot_bottom_right, :serenity_alive_path_from_observatory]
    ],
    storylines: [
      [30, 18, 5, 12, "Buffer-- has been set to: #{serenity_alive_sugarcoated_reply.quote}"],
      *serenity_alive_reply_completed_shared_hotspots(args),
    ]
  }
end

def serenity_alive_path_from_observatory args
  {
    fade: 60,
    background: 'sprites/path-to-observatory.png',
    player: [4, 21],
    scenes: [
      [*hotspot_bottom_right, :serenity_bio_infront_of_home]
    ],
    storylines: [
      [22, 20, 10, 10, "I'm not sure what's-- worse. Waiting-- for Sasha's-- reply. Or jumping-- off- from- right- here."]
    ]
  }
end

def serenity_alive_reply_completed_shared_hotspots args
  [
    [30, 10, 5, 4, "I guess it wasn't-- a joke- after-- all."],
    [40, 10, 5, 4, "I barely-- remember--- the- history----- of the crew."],
    [50, 10, 5, 4, "It probably--- wouldn't-- hurt- to- refresh-- my memory--."]
  ]
end

def serenity_alive_last_reply args
  if args.state.scene_history.include? :replied_to_introduction_seriously
    return "Buffer--: \"Hello, Who- is sending-- this message--?\""
  else
    return "Buffer--: \"New- phone. Who dis?\""
  end
end

def serenity_alive_current_message args
  if args.state.scene_history.include? :replied_to_introduction_seriously
    "This- is Sasha. The Serenity--- crew-- is out of hibernation---- and ready-- for Earth reentry--. But, it seems like we are having-- trouble-- with our Navigation---- systems. Please advise.".quote
  else
    "LOL! Thanks for the laugh. I needed that. This- is Sasha. The Serenity--- crew-- is out of hibernation---- and ready-- for Earth reentry--. But, it seems like we are having-- trouble-- with our Navigation---- systems. Can you help me out- babe?".quote
  end
end
