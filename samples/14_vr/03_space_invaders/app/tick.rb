class Game
  attr_gtk

  def tick
    grid.origin_center!
    defaults
    outputs.background_color = [0, 0, 0]
    args.outputs.sprites << state.enemies.map { |e| enemy_prefab e }.to_a
  end

  def defaults
    state.enemy_sprite_size = 64
    state.row_size = 16
    state.max_rows = 20
    state.enemies ||= 32.map_with_index do |i|
      x = i % 16
      y = i.idiv 16
      { row: y, col: x }
    end
  end

  def enemy_prefab enemy
    if enemy.row > state.max_rows
      raise "#{enemy}"
    end
    relative_row = enemy.row + 1
    z = 50 - relative_row * 10
    x = (enemy.col * state.enemy_sprite_size) - (state.enemy_sprite_size * state.row_size).idiv(2)
    enemy_sprite(x, enemy.row * 10 + 100, z * 10, enemy)
  end

  def enemy_sprite x, y, z, meta
    index = 0.frame_index count: 2, hold_for: 50, repeat: true
    { x: x,
      y: y,
      z: z,
      w: state.enemy_sprite_size,
      h: state.enemy_sprite_size,
      path: 'sprites/enemy.png',
      source_x: 128 * index,
      source_y: 0,
      source_w: 128,
      source_h: 128,
      meta: meta }
  end
end

$game = Game.new

def tick_game args
  $game.args = args
  $game.tick
end

GTK.reset
