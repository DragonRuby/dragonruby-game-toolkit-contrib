def day_one_beginning args
  {
    background: 'sprites/side-of-home.png',
    player: [16, 13],
    scenes: [
      [0, 0, 64, 2, :day_one_infront_of_home],
    ],
    storylines: [
      [35, 10, 6, 6,  "Man. Hard to believe- that today- is the 20th--- anniversary-- of The Impact."]
    ]
  }
end

def day_one_infront_of_home args
  {
    background: 'sprites/front-of-home.png',
    player: [56, 23],
    scenes: [
      [43, 34, 10, 16, :day_one_home],
      [62, 0,  3, 40, :day_one_beginning],
      [0, 4, 3, 20, :day_one_ceremony]
    ],
    storylines: [
      [40, 20, 4, 4, "It looks like everyone- is already- at the rememberance-- ceremony."],
    ]
  }
end

def day_one_home args
  {
    background: 'sprites/inside-home.png',
    player: [34, 3],
    scenes: [
      [28, 0, 12, 2, :day_one_infront_of_home]
    ],
    storylines: [
      [
        38, 4, 4, 4, "My mansion- in all its glory! Okay yea, it's just a shipping- container-. Apparently-, it's nothing- like the luxuries- of the 2040's. But it's- all we have- in- this day and age. And it'll suffice."
      ],
      [
        28, 7, 4, 7,
        "Ahhh. My reading- couch. It's so comfortable--."
      ],
      [
        38, 21, 4, 4,
        "I'm- lucky- to have a computer--. I'm- one of the few people- with- the skills to put this- thing to good use."
      ],
      [
        45, 37, 4, 8,
        "This corner- of my home- is always- warmer-. It's cause of the ref~lected-- light- from the solar-- panels--, just on the other- side- of this wall. It's hard- to believe- there was o~nce-- an unlimited- amount- of electricity--."
      ],
      [
        32, 40, 8, 10,
        "This isn't- a good time- to sleep. I- should probably- head to the ceremony-."
      ],
      [
        25, 21, 5, 12,
        "Fifteen-- years- of computer-- science-- notes, neatly-- organized. Compiler--- Theory--, Linear--- Algebra---, Game-- Development---... Every-- subject-- imaginable--."
      ]
    ]
  }
end

def day_one_ceremony args
  {
    background: 'sprites/tribute.png',
    player: [57, 21],
    scenes: [
      [62, 0, 2, 40, :day_one_infront_of_home],
      [0, 24, 2, 40, :day_one_infront_of_library]
    ],
    storylines: [
      [53, 12, 3,  8,  "It's- been twenty- years since The Impact. Twenty- years, since Halley's-- Comet-- set Earth's- blue- sky on fire."],
      [45, 12, 3,  8,  "The space mission- sent to prevent- Earth's- total- destruction--, was a success. Only- 99.9%------ of the world's- population-- died-- that day. Hey, it's- better-- than 100%---- of humanity-- dying."],
      [20, 12, 23, 4, "The monument--- reads:---- Here- stands- the tribute-- to Space- Mission-- Serenity--- and- its- crew. You- have- given-- humanity--- a second-- chance."],
      [15, 12, 3,  8, "Rest- in- peace--- Matthew----, Sasha----, Aanka----"],
    ]
  }
end

def day_one_infront_of_library args
  {
    background: 'sprites/outside-library.png',
    player: [57, 21],
    scenes: [
      [62, 0, 2, 40, :day_one_ceremony],
      [49, 39, 6, 9, :day_one_library]
    ],
    storylines: [
      [50, 20, 4, 8,  "Shipping- containers-- as far- as the eye- can see. It's- rather- beautiful-- if you ask me. Even- though-- this- view- represents-- all- that's-- left- of humanity-."]
    ]
  }
end

def day_one_library args
  {
    background: 'sprites/library.png',
    player: [27, 4],
    scenes: [
      [0, 0, 64, 2, :end_day_one_infront_of_library]
    ],
    storylines: [
      [28, 22, 8, 4,  "I grew- up- in this library. I've- read every- book- here. My favorites-- were- of course-- anything- computer-- related."],
      [6, 32, 10, 6, "My favorite-- area--- of the library. The Science-- Section."]
    ]
  }
end

def end_day_one_infront_of_library args
  {
    background: 'sprites/outside-library.png',
    player: [51, 33],
    scenes: [
      [49, 39, 6, 9, :day_one_library],
      [62, 0, 2, 40, :end_day_one_monument],
    ],
    storylines: [
      [50, 27, 4, 4, "It's getting late. Better get some sleep."]
    ]
  }
end

def end_day_one_monument args
  {
    background: 'sprites/tribute.png',
    player: [2, 36],
    scenes: [
      [62, 0, 2, 40, :end_day_one_infront_of_home],
    ],
    storylines: [
      [50, 27, 4, 4, "It's getting late. Better get some sleep."],
    ]
  }
end

def end_day_one_infront_of_home args
  {
    background: 'sprites/front-of-home.png',
    player: [1, 17],
    scenes: [
      [43, 34, 10, 16, :end_day_one_home],
    ],
    storylines: [
      [20, 10, 4, 4, "It's getting late. Better get some sleep."],
    ]
  }
end

def end_day_one_home args
  {
    background: 'sprites/inside-home.png',
    player: [34, 3],
    scenes: [
      [32, 40, 8, 10, :end_day_one_dream],
    ],
    storylines: [
      [38, 4, 4, 4, "It's getting late. Better get some sleep."],
    ]
  }
end

def end_day_one_dream args
  {
    background: 'sprites/dream.png',
    fade: 60,
    player: [4, 4],
    scenes: [
      [62, 0, 2, 64, :explaining_the_special_power]
    ],
    storylines: [
      [10, 10, 4, 4, "Why- does this- moment-- always- haunt- my dreams?"],
      [20, 10, 4, 4, "This kid- reads these computer--- science--- books- nonstop-. What's- wrong with him?"],
      [30, 10, 4, 4, "There- is nothing-- wrong- with him. This behavior-- should be encouraged---! In fact-, I think- he's- special---. Have- you seen- him use- a computer---? It's-- almost-- as if he can- speak-- to it."]
    ]
  }
end

def explaining_the_special_power args
  {
    fade: 60,
    background: 'sprites/inside-home.png',
    player: [32, 30],
    scenes: [
      [
        38, 21, 4, 4, :explaining_the_special_power_inside_computer
      ],
    ]
  }
end

def explaining_the_special_power_inside_computer args
  {
    background: 'sprites/pc.png',
    fade: 60,
    player: [34, 4],
    scenes: [
      [0, 62, 64, 3, :the_blinking_light]
    ],
    storylines: [
      [14, 20, 24, 4, "So... I have a special-- power--. I don't-- need a mouse-, keyboard--, or even-- a monitor--- to control-- a computer--."],
      [14, 25, 24, 4, "I only-- pretend-- to use peripherals---, so as not- to freak- anyone--- out."],
      [14, 30, 24, 4, "Inside-- this silicon--- Universe---, is the only-- place I- feel- at peace."],
      [14, 35, 24, 4, "It's-- the only-- place where I don't-- feel alone."]
    ]
  }
end
