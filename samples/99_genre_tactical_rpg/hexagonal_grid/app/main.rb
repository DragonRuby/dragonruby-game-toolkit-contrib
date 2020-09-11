class HexagonTileGame
  attr_gtk

  def defaults
    state.tile_scale      = 1.3
    state.tile_size       = 80
    state.tile_w          = Math.sqrt(3) * state.tile_size.half
    state.tile_h          = state.tile_size * 3/4
    state.tiles_x_count   = 1280.idiv(state.tile_w) - 1
    state.tiles_y_count   = 720.idiv(state.tile_h) - 1
    state.world_width_px  = state.tiles_x_count * state.tile_w
    state.world_height_px = state.tiles_y_count * state.tile_h
    state.world_x_offset  = (1280 - state.world_width_px).half
    state.world_y_offset  = (720 - state.world_height_px).half
    state.tiles         ||= state.tiles_x_count.map_with_ys(state.tiles_y_count) do |ordinal_x, ordinal_y|
      {
        ordinal_x: ordinal_x,
        ordinal_y: ordinal_y,
        offset_x: (ordinal_y.even?) ?
                  (state.world_x_offset + state.tile_w.half.half) :
                  (state.world_x_offset - state.tile_w.half.half),
        offset_y: state.world_y_offset,
        w: state.tile_w,
        h: state.tile_h,
        type: :blank,
        path: "sprites/hexagon-gray.png",
        a: 20
      }.associate do |h|
        h.merge(x: h[:offset_x] + h[:ordinal_x] * h[:w],
                y: h[:offset_y] + h[:ordinal_y] * h[:h]).scale_rect(state.tile_scale)
      end.associate do |h|
        h.merge(center: {
                  x: h[:x] + h[:w].half,
                  y: h[:y] + h[:h].half
                }, radius: [h[:w].half, h[:h].half].max)
      end
    end
  end

  def input
    if inputs.click
      tile = state.tiles.find { |t| inputs.click.point_inside_circle? t[:center], t[:radius] }
      if tile
        tile[:a] = 255
        tile[:path] = "sprites/hexagon-black.png"
      end
    end
  end

  def tick
    defaults
    input
    render
  end

  def render
    outputs.sprites << state.tiles
  end
end

$game = HexagonTileGame.new

def tick args
  $game.args = args
  $game.tick
end

$gtk.reset
