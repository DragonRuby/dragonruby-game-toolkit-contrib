def card_prefab args, id, x, y, name
  # Use Layout.rect's extended properties to set the card container's
  # origin to bottom left, remove the safe area, and include the gutters/margins
  # of the grid
  card_rect = Layout.rect(row: 0,
                          col: 0,
                          w: 4,
                          h: 6,
                          origin: :bottom_left,
                          safe_area: false,
                          include_row_gutter: true,
                          include_col_gutter: true)

  # define the image location for the card
  card_image_rect = Layout.rect(row: 2,
                                col: 0,
                                w: 4,
                                h: 4,
                                safe_area: false,
                                origin: :bottom_left)

  # define the location of the text for the card
  card_text_pos = Layout.rect(row: 0,
                              col: 0,
                              w: 4,
                              h: 2,
                              safe_area: false,
                              origin: :bottom_left).center

  # set the render target's w and h to be the container size (the name of the render target
  # is the card id
  args.outputs[id].w = card_rect.w
  args.outputs[id].h = card_rect.h

  # set the background color, image, and text for the card
  args.outputs[id].background_color = [255, 255, 255]
  args.outputs[id].primitives << card_image_rect.merge(path: :solid, r: 0, g: 80, b: 0)
  args.outputs[id].primitives << card_text_pos.merge(text: name, r: 0, g: 0, b: 0, anchor_x: 0.5, anchor_y: 0.5, size_px: 30)

  # return a sprite who's path is the card id/render target name
  { x: x, y: y, w: card_rect.w, h: card_rect.h, path: id, anchor_x: 0.5, anchor_y: 0.5  }
end

def tick args
  args.outputs.background_color = [0, 0, 0]
  args.outputs.primitives << card_prefab(args, :card_1, 440, 360, "Card 1")
  args.outputs.primitives << card_prefab(args, :card_2, 840, 360, "Card 2").merge(angle: 90)
end
