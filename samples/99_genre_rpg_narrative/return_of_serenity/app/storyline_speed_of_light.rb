def speed_of_light_front_of_home args
  {
    background: 'sprites/front-of-home.png',
    player: [54, 23],
    scenes: [
      [44, 34, 8, 14, :speed_of_light_inside_home],
      [0, 3, 3, 22, :speed_of_light_outside_library]
    ]
  }
end

def speed_of_light_inside_home args
  {
    background: 'sprites/inside-home.png',
    player: [35, 4],
    storylines: [
      [30, 38, 12, 13, "Can't- sleep right now. I have to- find- out- why- it took- over-- 4- hours-- to receive-- that message."]
    ],
    scenes: [
      [32, 0, 8, 3, :speed_of_light_front_of_home],
    ]
  }
end

def speed_of_light_outside_library args
  {
    background: 'sprites/outside-library.png',
    player: [55, 19],
    scenes: [
      [49, 39, 6, 10, :speed_of_light_library],
      [61, 11, 3, 20, :speed_of_light_front_of_home]
    ]
  }
end

def speed_of_light_library args
  {
    background: 'sprites/library.png',
    player: [30, 7],
    scenes: [
      [3, 50, 10, 3, :speed_of_light_celestial_bodies_diagram]
    ]
  }
end

def speed_of_light_celestial_bodies_diagram args
  {
    background: 'sprites/planets.png',
    fade: 60,
    player: [30, 3],
    scenes: [
      [56 - 2, 10, 5, 5, :speed_of_light_distance_discovered]
    ],
    storylines: [
      [30, 2, 4, 4, "Here- it is! This is a diagram--- of the solar-- system--. It was printed-- over-- fifty-- years- ago. Geez-- that's-- old."],

      [ 0 - 2, 10, 5, 5, "The label- reads: Sun. The length- of the Astronomical-------- Unit-- (AU), is the distance-- from the Sun- to the Earth. Which is about 150--- million--- kilometers----."],
      [ 7 - 2, 10, 5, 5, "The label- reads: Mercury. Distance from Sun: 0.39AU------------ or- 3----- light-- minutes--."],
      [14 - 2, 10, 5, 5, "The label- reads: Venus. Distance from Sun: 0.72AU------------ or- 6----- light-- minutes--."],
      [21 - 2, 10, 5, 5, "The label- reads: Earth. Distance from Sun: 1.00AU------------ or- 8----- light-- minutes--."],
      [28 - 2, 10, 5, 5, "The label- reads: Mars. Distance from Sun: 1.52AU------------ or- 12----- light-- minutes--."],
      [35 - 2, 10, 5, 5, "The label- reads: Jupiter. Distance from Sun: 5.20AU------------ or- 45----- light-- minutes--."],
      [42 - 2, 10, 5, 5, "The label- reads: Saturn. Distance from Sun: 9.53AU------------ or- 79----- light-- minutes--."],
      [49 - 2, 10, 5, 5, "The label- reads: Uranus. Distance from Sun: 19.81AU------------ or- 159----- light-- minutes--."],
      # [56 - 2, 15, 4, 4, "The label- reads: Neptune. Distance from Sun: 30.05AU------------ or- 4.1----- light-- hours--."],
      [63 - 2, 10, 5, 5, "The label- reads: Pluto. Wait. WTF? Pluto-- isn't-- a planet."],
    ]
  }
end

def speed_of_light_distance_discovered args
  {
    background: 'sprites/planets.png',
    scenes: [
      [13, 0, 44, 3, :speed_of_light_end_of_day]
    ],
    storylines: [
      [ 0 - 2, 10, 5, 5, "The label- reads: Sun. The length- of the Astronomical-------- Unit-- (AU), is the distance-- from the Sun- to the Earth. Which is about 150--- million--- kilometers----."],
      [ 7 - 2, 10, 5, 5, "The label- reads: Mercury. Distance from Sun: 0.39AU------------ or- 3----- light-- minutes--."],
      [14 - 2, 10, 5, 5, "The label- reads: Venus. Distance from Sun: 0.72AU------------ or- 6----- light-- minutes--."],
      [21 - 2, 10, 5, 5, "The label- reads: Earth. Distance from Sun: 1.00AU------------ or- 8----- light-- minutes--."],
      [28 - 2, 10, 5, 5, "The label- reads: Mars. Distance from Sun: 1.52AU------------ or- 12----- light-- minutes--."],
      [35 - 2, 10, 5, 5, "The label- reads: Jupiter. Distance from Sun: 5.20AU------------ or- 45----- light-- minutes--."],
      [42 - 2, 10, 5, 5, "The label- reads: Saturn. Distance from Sun: 9.53AU------------ or- 79----- light-- minutes--."],
      [49 - 2, 10, 5, 5, "The label- reads: Uranus. Distance from Sun: 19.81AU------------ or- 159----- light-- minutes--."],
      [56 - 2, 10, 5, 5, "The label- reads: Neptune. Distance from Sun: 30.05AU------------ or- 4.1----- light-- hours--. What?! The message--- I received-- was from a source-- farther-- than-- Neptune?!"],
      [63 - 2, 10, 5, 5, "The label- reads: Pluto. Dista- Wait... Pluto-- isn't-- a planet. People-- thought- Pluto-- was a planet-- back- then?--"],
    ]
  }
end

def speed_of_light_end_of_day args
  {
    fade: 60,
    background: 'sprites/inside-home.png',
    player: [35, 0],
    storylines: [
      [35, 10, 4, 4, "Wonder-- what the reply-- will be. Who- the hell is contacting--- me from beyond-- Neptune? This- has to be some- kind- of- joke."]
    ],
    scenes: [
      [31, 38, 10, 12, :serenity_alive_side_of_home]
    ]
  }
end
