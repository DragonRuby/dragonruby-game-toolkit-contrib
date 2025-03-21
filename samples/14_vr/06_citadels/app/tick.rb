class Game
  attr_gtk

  def citadel x, y, z
    angle = Kernel.tick_count.idiv(10) % 360
    adjacent = 40
    adjacent = adjacent.ceil
    angle = Math.atan2(40, 70).to_degrees
    y += 500
    x -= 40
    back_sprites = [
      { z: z - 40 + adjacent.half,
        x: x,
        y: y + 75,
        w: 80, h: 80, angle_x: angle, path: "sprites/triangle/equilateral/blue.png" },
      { z: z - 40,
        x: x,
        y: y - 400 + 80,
        w: 80, h: 400, path: "sprites/square/blue.png" },
    ]

    left_sprites = [
      { z: z,
        x: x - 40 + adjacent.half,
        y: y + 75,
        w: 80, h: 80, angle_x: -angle, angle_y: 90, path: "sprites/triangle/equilateral/blue.png" },
      { z: z,                      x: x - 40,
        y: y - 400 + 80,
        w: 80, h: 400, angle_y: 90, path: "sprites/square/blue.png" },
    ]

    right_sprites = [
      { z: z,
        x: x + 40 - adjacent.half,
        y: y + 75,
        w: 80, h: 80, angle_x: angle, angle_y: 90, path: "sprites/triangle/equilateral/blue.png" },
      { z: z,
        x: x + 40,
        y: y - 400 + 80,
        w: 80, h: 400, angle_y: 90, path: "sprites/square/blue.png" },
    ]

    front_sprites = [
      { z: z + 40 - adjacent.half,
        x: x,
        y: y + 75,
        w: 80, h: 80, angle_x: -angle, path: "sprites/triangle/equilateral/blue.png" },
      { z: z + 40,
        x: x,
        y: y - 400 + 80,
        w: 80, h: 400, path: "sprites/square/blue.png" },
    ]

    if x > 700
      [
        back_sprites,
        right_sprites,
        front_sprites,
        left_sprites,
      ]
    elsif x < 600
      [
        back_sprites,
        left_sprites,
        front_sprites,
        right_sprites,
      ]
    else
      [
        back_sprites,
        left_sprites,
        right_sprites,
        front_sprites,
      ]
    end

  end

  def tick
    state.z ||= 200
    state.z += inputs.controller_one.right_analog_y_perc
    state.columns ||= 100.map do
      {
        x: rand(12) * 400,
        y: 0,
        z: rand(12) * 400,
      }
    end

    outputs.sprites << state.columns.map do |col|
      citadel(col.x - 640, col.y - 400, state.z - col.z)
    end
  end
end

$game = Game.new

def tick_game args
  $game.args = args
  $game.tick
end

GTK.reset
