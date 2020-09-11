def final_decision_side_of_home args
  {
    fade: 120,
    background: 'sprites/side-of-home.png',
    player: [16, 13],
    scenes: [
      [52, 24, 11, 5, :final_decision_mountain_pass],
    ],
    render_override: :blinking_light_side_of_home_render,
    storylines: [
      [28, 13, 8, 4,  "Man. Hard to believe- that today- is the 21st--- anniversary-- of The Impact. Serenity--- will- be- home- soon."]
    ]
  }
end

def final_decision_mountain_pass args
  {
    background: 'sprites/mountain-pass-zoomed-out.png',
    player: [4, 4],
    scenes: [
      [18, 47, 5, 5, :final_decision_path_to_observatory]
    ],
    render_override: :blinking_light_mountain_pass_render
  }
end

def final_decision_path_to_observatory args
  {
    background: 'sprites/path-to-observatory.png',
    player: [60, 4],
    scenes: [
      [0, 26, 5, 5, :final_decision_observatory]
    ],
    render_override: :blinking_light_path_to_observatory_render
  }
end

def final_decision_observatory args
  {
    background: 'sprites/observatory.png',
    player: [60, 2],
    scenes: [
      [28, 39, 4, 10, :final_decision_inside_observatory]
    ],
    render_override: :blinking_light_observatory_render
  }
end

def final_decision_inside_observatory args
  {
    background: 'sprites/inside-observatory.png',
    player: [60, 2],
    storylines: [],
    scenes: [
      [30, 18, 5, 12, :final_decision_inside_mainframe]
    ],
    render_override: :blinking_light_inside_observatory_render
  }
end

def final_decision_inside_mainframe args
  {
    player: [32, 4],
    background: 'sprites/mainframe.png',
    storylines: [],
    scenes: [
      [*hotspot_top, :final_decision_ship_status],
    ]
  }
end

def final_decision_ship_status args
  {
    background: 'sprites/serenity.png',
    fade: 60,
    player: [30, 10],
    scenes: [
      [*hotspot_top_right, :final_decision]
    ],
    storylines: [
      [30,  8, 4, 4, "????"],
      *final_decision_ship_status_shared(args)
    ]
  }
end

def final_decision args
  decision_graph  "Stasis-- Chambers--: UNDERPOWERED, Life- forms-- will be terminated---- unless-- equilibrium----- is reached.",
                  "I CAN'T DO THIS... But... If-- I-- don't--- bring-- the- chambers--- to- equilibrium-----, they all die...",
                  [:final_decision_game_over_noone, "Kill--- Everyone---", "DO--- NOTHING?"],
                  [:final_decision_game_over_matthew, "Kill--- Sasha---", "KILL--- SASHA?"],
                  [:final_decision_game_over_anka, "Kill--- Aanka---", "KILL--- AANKA?"],
                  [:final_decision_game_over_sasha, "Kill--- Matthew---", "KILL--- MATTHEW?"]
end

def final_decision_game_over_noone args
  {
    background: 'sprites/tribute-game-over.png',
    player: [53, 14],
    fade: 600
  }
end

def final_decision_game_over_matthew args
  {
    background: 'sprites/tribute-game-over.png',
    player: [53, 14],
    fade: 600
  }
end

def final_decision_game_over_anka args
  {
    background: 'sprites/tribute-game-over.png',
    player: [53, 14],
    fade: 600
  }
end

def final_decision_game_over_sasha args
  {
    background: 'sprites/tribute-game-over.png',
    player: [53, 14],
    fade: 600
  }
end

def final_decision_ship_status_shared args
  [
    *ship_control_hotspot(24, 22,
                           "Stasis-- Chambers--: UNDERPOWERED, Life- forms-- will be terminated---- unless-- equilibrium----- is reached. WHAT?! NO!",
                           "Matthew's--- Chamber--: UNDER-- THREAT-- OF-- TERMINATION. WHAT?! NO!",
                           "Aanka's--- Chamber--: UNDER-- THREAT-- OF-- TERMINATION.  WHAT?! NO!",
                           "Sasha's--- Chamber--: UNDER-- THREAT-- OF-- TERMINATION. WHAT?! NO!"),
  ]
end
