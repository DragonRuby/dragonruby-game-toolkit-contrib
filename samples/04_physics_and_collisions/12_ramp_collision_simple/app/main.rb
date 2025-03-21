class Game
  attr :args

  def defaults
    state.terrain ||= [
      { x:   0,  y:  0, w: 128, h: 128, left_perc: 0,   right_perc: 0.5 },
      { x: 128,  y: 64, w: 128, h: 128, left_perc: 0,   right_perc: 1.0 },
      { x: 256,  y: 64, w: 128, h: 128, left_perc: 1.0, right_perc: 0 },
      { x: 384,  y: 64, w: 128, h: 128, left_perc: 0,   right_perc: 0 },
      { x: 512,  y: 64, w: 128, h: 128, left_perc: 0,   right_perc: 0 },
      { x: 640,  y:  0, w: 128, h: 128, left_perc: 0.5, right_perc: 0 },
      { x: 768,  y:  0, w: 128, h: 128, left_perc: 0,   right_perc: 1.0 },
    ]

    state.player ||= {
      x: 100,
      y: 720,
      w: 32,
      h: 32,
      dx: 0,
      dy: 0,
      on_ground: false
    }
  end

  def tick
    defaults
    calc
    render
  end

  def calc
    if inputs.keyboard.right
      player.dx = 2
    elsif inputs.keyboard.left
      player.dx = -2
    end

    if inputs.keyboard.key_down.space && player.on_ground
      player.dy = 8
      player.on_ground = false
    end

    if player.y + player.h < 0
      player.x = 100
      player.y = 720
    end

    player.prev_y = player.y
    player.x += player.dx
    player.dx *= 0.9
    player.dy -= 0.2
    player.dy = player.dy.clamp(-8, 8)
    player.y += player.dy
    collisions = Geometry.find_all_intersect_rect(player_feet_box, state.terrain)

    collision = collisions.map do |c|
      r = { rect: c, ramp_y: ramp_y_for_x(player.x, c) }
      r.delta_y = (player.y - (c.y + r.ramp_y))
      r
    end.sort_by { |c| c.delta_y.abs }.first # sort by the smallest ramp delta

    if collision
      if clipping_ramp?(player.y, collision)
        player.y = collision.rect.y + collision.ramp_y
        player.on_ground = true
      elsif player.on_ground
        player.dy = 0
        player.y = player.prev_y
        player.on_ground = false
      end
    elsif player.on_ground
      player.dy = 0
      player.y = player.prev_y
      player.on_ground = false
    end
  end

  def render
    outputs.background_color = [0, 0, 0]
    outputs.primitives << state.terrain.map { |t| ramp_prefab(t) }
    outputs.primitives << state.player.merge(path: :solid, r: 255, g: 255, b: 255, anchor_x: 0.5, anchor_y: 0)
    outputs.primitives << player_feet_box.merge(path: :solid, r: 255, g: 0, b: 0, anchor_x: 0.5, anchor_y: 0)
  end

  def clipping_ramp? y, ramp
    clip_height = 16
    y < ramp.rect.y + ramp.ramp_y && y + clip_height > ramp.rect.y + ramp.ramp_y
  end

  def ramp_y_for_x x, ramp
    rel_x = (x - ramp.x).fdiv ramp.w
    ((ramp.right_perc - ramp.left_perc) * rel_x + ramp.left_perc) * ramp.h
  end

  def outputs
    @args.outputs
  end

  def state
    @args.state
  end

  def inputs
    @args.inputs
  end

  def player
    state.player
  end

  def player_feet_box
    { x: player.x, y: player.y, w: 2, h: 16, anchor_x: 0.5, anchor_y: 0 }
  end

  def ramp_prefab ramp
    { x:  ramp.x,
      y:  ramp.y + ramp.h * ramp.left_perc,
      x2: ramp.x + ramp.w,
      y2: ramp.y + ramp.h * ramp.right_perc,
      r: 255,
      g: 0,
      b: 0 }
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
