class Game
  attr_gtk

  def tick
    defaults
    render
    calc
  end

  def defaults
    state.player ||= { x: 640,
                       y: 720 - 64,
                       dy: 0,
                       dx: 0,
                       radius: 20 }

    state.pegs ||= [
      { x: 620, y: 360, radius: 20 },
      { x: 920, y: 416, radius: 20 },
    ]

    state.gravity ||= 0.5
  end

  def render
    outputs.background_color = [0, 0, 0]
    outputs.sprites << circle_prefab(player, "sprites/circle/blue.png")
    outputs.sprites << state.pegs.map { |peg| circle_prefab(peg, "sprites/circle/red.png") }
  end

  def calc
    player.dy -= state.gravity
    player.dy = player.dy.clamp(-15, 15)
    player.x += player.dx
    player.y += player.dy

    if player.y < 0 || player.x < 0 || player.x > 1280
      player.dx = 0
      player.dy = 0
      player.x = 640
      player.y = 720 - 64
    end

    collision = state.pegs.find do |peg|
      Geometry.intersect_circle? player, peg
    end

    if collision
      distance =   Geometry.distance player, collision
      force = Geometry.vec2_subtract collision, player
      normalized = Geometry.vec2_normalize force

      # "axis aligned bounding circle"
      aabc = Geometry.vec2_scale(force, -1)
      aabc = Geometry.vec2_scale(aabc, player.radius + collision.radius)
      aabc = Geometry.vec2_scale(aabc, 1 / distance)
      player.merge! Geometry.vec2_add(collision, aabc)

      reflect = Geometry.vec2_scale normalized, player.dy
      reflect = Geometry.vec2_scale reflect, 0.8
      player.dx = reflect.x
      player.dy = reflect.y
    end
  end

  def player
    state.player
  end

  def circle_prefab peg, path
    { x: peg.x,
      y: peg.y,
      w: peg.radius * 2,
      h: peg.radius * 2,
      path: path,
      anchor_x: 0.5,
      anchor_y: 0.5 }
  end
end

def boot args
  args.state = {}
end

def tick args
  $game ||= Game.new
  $game.args = args
  $game.tick
end

def reset args
  $game = nil
end

GTK.reset
