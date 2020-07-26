# decision_graph "Message from Sasha",
#                "I should reply.",
#                [:replied_to_introduction_seriously,  "Reply Seriously", "Who is this?"],
# [:replied_to_introduction_humorously, "Reply Humorously", "New phone who dis?"]
def reply_to_introduction args
  decision_graph  "\"Mission-- control--, your- main- comm-- channels-- seem-- to be down. My apologies-- for- using-- this low- level-- exploit--. What's-- going-- on down there? We are ready-- for reentry--.\" Message--- Timestamp---: 4- hours-- 23--- minutes-- ago--.",
                  "Whoever-- pulled- off this exploit-- knows their stuff. I should reply--.",
                  [:replied_to_introduction_seriously,  "Serious Reply",  "Hello, Who- is sending-- this message--?"],
                  [:replied_to_introduction_humorously, "Humorous Reply", "New phone, who dis?"]
end

def replied_to_introduction_seriously args
  {
    background: 'sprites/inside-observatory.png',
    fade: 60,
    player: [32, 21],
    scenes: [
      *replied_to_introduction_shared_scenes(args)
    ],
    storylines: [
      [30, 18, 5, 12, "Buffer-- has been set to: \"Hello, Who- is sending-- this message--?\""],
      *replied_to_introduction_shared_storylines(args)
    ]
  }
end

def replied_to_introduction_humorously args
  {
    background: 'sprites/inside-observatory.png',
    fade: 60,
    player: [32, 21],
    scenes: [
      *replied_to_introduction_shared_scenes(args)
    ],
    storylines: [
      [30, 18, 5, 12, "Buffer-- has been set to: \"New- phone. Who dis?\""],
      *replied_to_introduction_shared_storylines(args)
    ]
  }
end

def replied_to_introduction_shared_storylines args
  [
    [30, 10, 5, 4, "It's-- going-- to take a while-- for this reply-- to make it's-- way back."],
    [40, 10, 5, 4, "4- hours-- to send a message-- at light speed?! How far away-- is the sender--?"],
    [50, 10, 5, 4, "I know- I've-- read about-- light- speed- travel-- before--. Maybe-- the library--- still has that- poster."]
  ]
end

def replied_to_introduction_shared_scenes args
  [[60, 0, 4, 32, :replied_to_introduction_observatory]]
end

def replied_to_introduction_observatory args
  {
    background: 'sprites/observatory.png',
    player: [28, 39],
    scenes: [
      [60, 0, 4, 32, :replied_to_introduction_path_to_observatory]
    ]
  }
end

def replied_to_introduction_path_to_observatory args
  {
    background: 'sprites/path-to-observatory.png',
    player: [0, 26],
    scenes: [
      [60, 0, 4, 20, :replied_to_introduction_mountain_pass]
    ],
  }
end

def replied_to_introduction_mountain_pass args
  {
    background: 'sprites/mountain-pass-zoomed-out.png',
    player: [21, 48],
    scenes: [
      [0, 0, 15, 4, :replied_to_introduction_side_of_home]
    ],
    storylines: [
      [15, 28, 5, 3, "At least I'm-- getting-- my- exercise-- in- for- today--."]
    ]
  }
end

def replied_to_introduction_side_of_home args
  {
    background: 'sprites/side-of-home.png',
    player: [58, 29],
    scenes: [
      [2, 0, 61, 2, :speed_of_light_front_of_home]
    ],
  }
end
