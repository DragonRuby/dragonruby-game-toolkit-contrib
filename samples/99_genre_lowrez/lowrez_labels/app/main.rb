# sample app demonstrates how fonts are rendered at the top level and within a low rez render target
class Game
  attr_gtk

  def tick
    outputs.primitives << Layout.rect(row: 0, col: 0, w: 4, h: 4)
                                .merge(path: :solid, r: 128, g: 128, b: 128, w: 16, h: 16)
    outputs.primitives << Layout.rect(row: 0, col: 0, w: 4, h: 4)
                                .merge(text: "+", font: "fonts/lowrez.ttf", anchor_x: 0, anchor_y: 0, size_px: 16)

    outputs.primitives << Layout.rect(row: 0, col: 4, w: 4, h: 4)
                                .merge(path: :solid, r: 128, g: 128, b: 128, w: 32, h: 32)
    outputs.primitives << Layout.rect(row: 0, col: 4, w: 4, h: 4)
                                .merge(text: "+", font: "fonts/lowrez.ttf", anchor_x: 0, anchor_y: 0, size_px: 32)

    outputs.primitives << Layout.rect(row: 0, col: 8, w: 4, h: 4)
                                .merge(path: :solid, r: 128, g: 128, b: 128, w: 64, h: 64)
    outputs.primitives << Layout.rect(row: 0, col: 8, w: 4, h: 4)
                                .merge(text: "+", font: "fonts/lowrez.ttf", anchor_x: 0, anchor_y: 0, size_px: 64)

    outputs.primitives << Layout.rect(row: 0, col: 12, w: 4, h: 4)
                                .merge(path: :solid, r: 128, g: 128, b: 128, w: 128, h: 128)
    outputs.primitives << Layout.rect(row: 0, col: 12, w: 4, h: 4)
                                .merge(text: "+", font: "fonts/lowrez.ttf", anchor_x: 0, anchor_y: 0, size_px: 128)

    # to avoid visual artifacts, you want to scale render targets down to smaller powers of two
    # otherwise labels will have rendering artifacts
    # for lowrez games, be sure that your RT size is always a power of two and are scaled by a power of two
    outputs[:lowrez_text].w = 128
    outputs[:lowrez_text].h = 128
    outputs[:lowrez_text].primitives << { x: 0, y: 0, w: 128, h: 128, r: 128, g: 128, b: 128, path: :solid }
    outputs[:lowrez_text].primitives << { x: 0, y: 0, anchor_y: 0, anchor_y: 0, text: "+", size_px: 128, font: "fonts/lowrez.ttf" }

    outputs.primitives << Layout.rect(row: 0, col: 1, w: 4, h: 4)
                                .merge(path: :lowrez_text, w: 16, h: 16) # 128 scaled down to 16x16

    outputs.primitives << Layout.rect(row: 0, col: 3, w: 4, h: 4)
                                .merge(path: :lowrez_text, w: 32, h: 32) # 128 scaled down to 32x32

    outputs.primitives << Layout.rect(row: 0, col: 10, w: 4, h: 4)
                                .merge(path: :lowrez_text, w: 64, h: 64) # 128 scaled down to 64x64

    outputs.primitives << Layout.rect(row: 0, col: 15, w: 4, h: 4)
                                .merge(path: :lowrez_text, w: 128, h: 128)

    outputs.primitives << Layout.debug_primitives
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
