def the_blinking_light args
  {
    fade: 60,
    background: 'sprites/side-of-home.png',
    player: [16, 13],
    scenes: [
      [52, 24, 11, 5, :blinking_light_mountain_pass],
    ],
    render_override: :blinking_light_side_of_home_render
  }
end

def blinking_light_mountain_pass args
  {
    background: 'sprites/mountain-pass-zoomed-out.png',
    player: [4, 4],
    scenes: [
      [18, 47, 5, 5, :blinking_light_path_to_observatory]
    ],
    render_override: :blinking_light_mountain_pass_render
  }
end

def blinking_light_path_to_observatory args
  {
    background: 'sprites/path-to-observatory.png',
    player: [60, 4],
    scenes: [
      [0, 26, 5, 5, :blinking_light_observatory]
    ],
    render_override: :blinking_light_path_to_observatory_render
  }
end

def blinking_light_observatory args
  {
    background: 'sprites/observatory.png',
    player: [60, 2],
    scenes: [
      [28, 39, 4, 10, :blinking_light_inside_observatory]
    ],
    render_override: :blinking_light_observatory_render
  }
end

def blinking_light_inside_observatory args
  {
    background: 'sprites/inside-observatory.png',
    player: [60, 2],
    storylines: [
      [50, 2, 4, 8,   "That's weird. I thought- this- mainframe-- was broken--."]
    ],
    scenes: [
      [30, 18, 5, 12, :blinking_light_inside_mainframe]
    ],
    render_override: :blinking_light_inside_observatory_render
  }
end

def blinking_light_inside_mainframe args
  {
    background: 'sprites/mainframe.png',
    fade: 60,
    player: [30, 4],
    scenes: [
      [62, 32, 4, 32, :reply_to_introduction]
    ],
    storylines: [
      [43, 43,  8, 8, "\"Mission-- control--, your- main- comm-- channels-- seem-- to be down. My apologies-- for- using-- this low- level-- exploit--. What's-- going-- on down there? We are ready-- for reentry--.\" Message--- Timestamp---: 4- hours-- 23--- minutes-- ago--."],
      [30, 30,  4, 4, "There's-- a low- level-- message-- here... NANI.T.F?"],
      [14, 10, 24, 4, "Oh interesting---. This transistor--- needed-- to be activated--- for the- mainframe-- to work."],
      [14, 20, 24, 4, "What the heck activated--- this thing- though?"]
    ]
  }
end
