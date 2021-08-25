def serenity_bio_infront_of_home args
  {
    fade: 60,
    background: 'sprites/front-of-home.png',
    player: [54, 23],
    scenes: [
      [44, 34, 8, 14, :serenity_bio_inside_home],
      [0, 3, 3, 22, :serenity_bio_library]
    ]
  }
end

def serenity_bio_inside_home args
  {
    background: 'sprites/inside-home.png',
    player: [34, 4],
    storylines: [
      [34, 4, 4, 4, "I'm--- completely--- exhausted."],
    ],
    scenes: [
      [30, 38, 12, 13, :serenity_bio_restless_sleep],
      [32, 0, 8, 3, :serenity_bio_infront_of_home],
    ]
  }
end

def serenity_bio_restless_sleep args
  {
    fade: 60,
    background: 'sprites/inside-home.png',
    storylines: [
      [32, 38, 10, 13, "I can't-- seem to sleep. I know nothing-- about the- crew-. Maybe- I- should- go read- up- on- them."],
    ],
    scenes: [
      [32, 0, 8, 3, :serenity_bio_infront_of_home],
    ]
  }
end

def serenity_bio_library args
  {
    background: 'sprites/library.png',
    fade: 60,
    player: [30, 7],
    scenes: [
      [21, 35, 3, 18, :serenity_bio_book]
    ]
  }
end

def serenity_bio_book args
  {
    background: 'sprites/book.png',
    fade: 60,
    player: [6, 52],
    storylines: [
      [ 4, 50, 56, 4, "The Title-- Reads: Never-- Forget-- Mission-- Serenity---"],

      [ 4, 38,  8, 8, "Name: Matthew--- R. Sex: Male--- Age-- at-- Departure: 36-----"],
      [14, 38, 46, 8, "Tribute-- Text: Matthew graduated-- Magna-- Cum-- Laude-- from MIT--- with-- a- PHD---- in Aero-- Nautical--- Engineering. He was immensely--- competitive, and had an insatiable---- thirst- for aerial-- battle. From the age of twenty, he remained-- undefeated--- in the Israeli-- Air- Force- \"Blue Flag\" combat-- exercises. By the age of 29--- he had already-- risen through- the ranks, and became-- the Lieutenant--- General--- of Lufwaffe. Matthew-- volenteered-- to- pilot-- Mission-- Serenity. To- this day, his wife- and son- are pillars-- of strength- for us. Rest- in Peace- Matthew, we are sorry-- that- news of the pregancy-- never-- reached- you. Please forgive us."],

      [4,  26,  8, 8, "Name: Aanka--- P. Sex: Female--- Age-- at-- Departure: 9-----"],
      [14, 26, 46, 8, "Tribute-- Text: Aanka--- gratuated--- Magna-- Cum- Laude-- from MIT, at- the- age- of eight, with a- PHD---- in Astro-- Physics. Her-- IQ--- was over 390, the highest-- ever- recorded--- IQ-- in- human-- history. She changed- the landscape-- of Physics-- with her efforts- in- unravelling--- the mysteries--- of- Dark- Matter--. Anka discovered-- the threat- of Halley's-- Comet-- collision--- with Earth. She spear headed-- the global-- effort-- for Misson-- Serenity. Her- multilingual--- address-- to- the world-- brought- us all hope."],

      [4,  14,  8, 8, "Name: Sasha--- N. Sex: Female--- Age-- at-- Departure: 29-----"],
      [14, 14, 46, 8, "Tribute-- Text: Sasha gratuated-- Magna-- Cum- Laude-- from MIT--- with-- a- PHD---- in Computer---- Science----. She-- was-- brilliant--, strong- willed--, and-- a-- stunningly--- beautiful--- woman---. Sasha---- is- the- creator--- of the world's--- first- Ruby--- Quantum-- Machine---. After-- much- critical--- acclaim--, the Quantum-- Computer-- was placed in MIT's---- Museam-- next- to- Richard--- G. and Thomas--- K.'s---- Lisp-- Machine---. Her- engineering--- skills-- were-- paramount--- for Mission--- Serenity's--- success. Humanity-- misses-- you-- dearly,-- Sasha--. Life-- shines-- a dimmer-- light-- now- that- your- angelic- voice-- can never- be heard- again."],
    ],
    scenes: [
      [*hotspot_bottom, :serenity_bio_finally_to_bed]
    ]
  }
end

def serenity_bio_finally_to_bed args
  {
    fade: 60,
    background: 'sprites/inside-home.png',
    player: [35, 3],
    storylines: [
      [34, 4, 4, 4, "Maybe-- I'll-- be able-- to sleep- now..."],
    ],
    scenes: [
      [32, 38, 10, 13, :bad_dream],
    ]
  }
end

def bad_dream args
  {
    fade: 120,
    background: 'sprites/inside-home.png',
    player: [34, 35],
    storylines: [
      [34, 34, 4, 4, "Man. I did not- sleep- well- at all..."],
    ],
    scenes: [
      [32, -1, 8, 3, :bad_dream_observatory]
    ]
  }
end

def bad_dream_observatory args
  {
    background: 'sprites/inside-observatory.png',
    fade: 120,
    player: [51, 12],
    storylines: [
      [50, 10, 4, 4,   "Breathe, Hiro. Just see what's there... everything--- will- be okay."]
    ],
    scenes: [
      [30, 18, 5, 12, :bad_dream_inside_mainframe]
    ],
    render_override: :blinking_light_inside_observatory_render
  }
end

def bad_dream_inside_mainframe args
  {
    player: [32, 4],
    background: 'sprites/mainframe.png',
    fade: 120,
    storylines: [
      [22, 45, 17, 4, (bad_dream_last_reply args)],
    ],
    scenes: [
      [45, 45,  4, 4, :bad_dream_everyone_dead],
    ]
  }
end

def bad_dream_everyone_dead args
  {
    background: 'sprites/mainframe.png',
    storylines: [
      [22, 45, 17, 4, (bad_dream_last_reply args)],
      [45, 45,  4, 4, "Hi-- Hiro. This is Sasha. By the time- you get this- message, chances-- are we will- already-- be- dead. The batteries--- got- damaged-- during-- removal. And- we don't-- have enough-- power-- for Life-- Support. The air-- is- already--- starting-- to taste- bad. It... would- have been- nice... to go- on a date--- with- you-- when-- I- got- back- to Earth. Anyways, good-- bye-- Hiro-- XOXOXO----"],
      [22,  5, 17, 4, "Meh. Whatever, I didn't-- want to save them anyways. What- a pain- in my ass."],
    ],
    scenes: [
      [*hotspot_bottom, :anka_inside_room]
    ]
  }
end

def bad_dream_last_reply args
  if args.state.scene_history.include? :replied_to_serenity_alive_firmly
    return "Buffer--: #{serenity_alive_firm_reply.quote}"
  else
    return "Buffer--: #{serenity_alive_sugarcoated_reply.quote}"
  end
end
