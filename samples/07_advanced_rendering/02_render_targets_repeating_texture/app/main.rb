# Sample app shows how to leverage render targets to create a repeating
# texture given a source sprite.
def tick args
  args.outputs.sprites << repeating_texture(args,
                                            x: 640,
                                            y: 360,
                                            w: 1280,
                                            h: 720,
                                            anchor_x: 0.5,
                                            anchor_y: 0.5,
                                            path: 'sprites/square/blue.png')
end

def repeating_texture args, x:, y:, w:, h:, path:, anchor_x: 0, anchor_y: 0
  # create an area to store state for function
  args.state.repeating_texture_lookup ||= {}

  # create a unique name for the repeating texture
  rt_name = "#{path.hash}-#{w}-#{h}"

  # if the repeating texture has not been created yet, create it
  if args.state.repeating_texture_lookup[rt_name]
    return { x: x,
             y: y,
             w: w,
             h: h,
             anchor_x: anchor_x,
             anchor_y: anchor_y,
             path: rt_name }
  end

  # create a render target to store the repeating texture
  args.outputs[rt_name].w = w
  args.outputs[rt_name].h = h

  # calculate the sprite box for the repeating texture
  sprite_w, sprite_h = GTK.calcspritebox path

  # calculate the number of rows and columns needed to fill the repeating texture
  rows = h.idiv(sprite_h) + 1
  cols = w.idiv(sprite_w) + 1

  # generate the repeating texture using a render target
  # this only needs to be done once and will be cached
  args.outputs[rt_name].sprites << rows.map do |r|
                                     cols.map do |c|
                                       { x: sprite_w * c,
                                         y:  h - sprite_h * (r + 1),
                                         w: sprite_w,
                                         h: sprite_h,
                                         path: path }
                                     end
                                   end

  # store a flag in state denoting that the repeating
  # texture has been generated
  args.state.repeating_texture_lookup[rt_name] = true

  # return the repeating texture
  repeating_texture args, x: x, y: y, w: w, h: h, path: path
end

GTK.reset
