# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# tweetcart.rb has been released under MIT (*only this file*).

def $top_level.TICK &block
  $top_level.define_method(:tick) do |args|
    args.outputs[:scene].transient!
    args.outputs[:scene].w = 160
    args.outputs[:scene].h = 90
    args.outputs[:scene].background_color = [0, 0, 0, 0]
    args.state.tweet_scene ||= { x: 0, y: 0, w: 1280, h: 720, path: :scene }
    args.state.tweet_scene_pixels ||= { x: 0, y: 0, w: 1280, h: 720, path: :pixels }
    $tweetcart_palette ||= create_tweetcart_palette
    block.call args

    if  $args.state.tweetcart_state.render_mode == :pixels
      args.outputs.sprites << args.state.tweet_scene_pixels
    else
      args.outputs.sprites << args.state.tweet_scene
    end
  end

  class << $top_level
    def no_clr! render_target_name = :scene
      no_clear! render_target_name
    end

    def no_clear! render_target_name = :scene
      $args.outputs[render_target_name].clear_before_render = false
    end

    def bg! *rgb
      r,g,b = rgb
      r ||= 255
      g ||= r
      b ||= g
      $args.outputs.background_color = [r, g, b]
    end

    def slds
      $args.outputs[:scene].sprites
    end

    def slds! *os
      if (os.first.is_a? Numeric)
        sld!(*os)
      else
        os.each { |o| sld!(*o) }
      end
    end

    def sld! *params
      x, y, w, h, r, g, b, a = nil
      if params.length == 2
        x, y = params
      elsif params.length == 3 && (params.last.is_a? Array)
        x = params[0]
        y = params[1]
        r, g, b, a = params[2]
        r ||= 255
        g ||= r
        b ||= g
        a ||= 255
      elsif params.length == 4
        x, y, w, h = params
      elsif params.length == 5 && (params.last.is_a? Array)
        x = params[0]
        y = params[1]
        w = params[2]
        h = params[3]
        r,g,b,a = params[4]
        r ||= 255
        g ||= r
        b ||= g
        a ||= 255
      elsif params.length >= 7
        x, y, w, h, r, g, b = params
      else
        raise "I don't know how to render #{params} with reasonable defaults."
      end

      w ||= 1
      h ||= 1
      r ||= 255
      g ||= 255
      b ||= 255
      a ||= 255

      slds << { x: x, y: y,
                w: w, h: h,
                r: r, g: g, b: b, a: a,
                path: :pixel }
    end

    def sin_r radians
      Math.sin radians
    end

    def cos_r radians
      Math.cos radians
    end

    def sin degrees
      Math.sin degrees.to_radians
    end

    def cos degrees
      Math.cos degrees.to_radians
    end

    def sin_d degrees
      Math.sin degrees.to_radians
    end

    def cos_d degrees
      Math.cos degrees.to_radians
    end

    def tc
      $args.state.tick_count
    end

    def scene! w = 1280, h = 720, scale = nil
      scale ||= begin
                  x_scale = $args.grid.w / w
                  y_scale = $args.grid.h / h
                  x_scale < y_scale ? x_scale : y_scale
                end

      $args.state.tweetcart_state.render_mode == :scene
      $args.outputs[:scene].w = w
      $args.outputs[:scene].h = h
      $args.state.tweet_scene.w = w * scale
      $args.state.tweet_scene.h = h * scale
      $args.state.tweet_scene.x = ($args.grid.w - w * scale) / 2
      $args.state.tweet_scene.y = ($args.grid.h - h * scale) / 2
    end

    def create_tweetcart_palette
      [
        [   0,   0,   0 ],
        [  34,  32,  52 ],
        [  69,  40,  60 ],
        [ 102,  57,  49 ],
        [ 143,  86,  59 ],
        [ 223, 113,  38 ],
        [ 217, 160, 102 ],
        [ 238, 195, 154 ],
        [ 251, 242,  54 ],
        [ 153, 229,  80 ],
        [ 106, 190,  48 ],
        [  55, 148, 110 ],
        [  75, 105,  47 ],
        [  82,  75,  36 ],
        [  50,  60,  57 ],
        [  63,  63, 116 ],
        [  48,  96, 130 ],
        [  91, 110, 225 ],
        [  99, 155, 255 ],
        [  95, 205, 228 ],
        [ 203, 219, 252 ],
        [ 255, 255, 255 ],
        [ 155, 173, 183 ],
        [ 132, 126, 135 ],
        [ 105, 106, 106 ],
        [  89,  86,  82 ],
        [ 118,  66, 138 ],
        [ 172,  50,  50 ],
        [ 217,  87,  99 ],
        [ 215, 123, 186 ],
        [ 143, 151,  74 ],
        [ 138, 111,  48 ]
      ]
    end

    def pal
      $tweetcart_palette
    end

    def pixels!
      return if $args.state.tweetcart_state.render_mode == :pixels
      tweetcart_state.render_mode = :pixels
      tweetcart_state.color = 0
      $args.pixel_array(:pixels).w = 160
      $args.pixel_array(:pixels).h = 90
      $args.pixel_array(:pixels).pixels.fill(0xFFFFFFFF, 0, 160 * 90)  # black, full alpha
    end

    def tweetcart_state
      $args.state.tweetcart_state ||= {}
    end

    def color pal_number
      tweetcart_state.color = pal_number
    end

    def pset x, y, pal_number = tweetcart_state.color
      r, g, b = pal[pal_number]
      abgr_hex = (255 << 24) + (b << 16) + (g << 8) + r
      row_increment = y * 160
      $args.pixel_array(:pixels).pixels.fill(abgr_hex, x + row_increment, 1)
    end

    def pget x, y
      row_increment = y * 160
      abgr_hex = $args.pixel_array(:pixels).pixels[x + row_increment]
      r = (abgr_hex & 0x000000FF)
      g = (abgr_hex & 0x0000FF00) >> 8
      b = (abgr_hex & 0x00FF0000) >> 16
      pal.index([r, g, b])
    end

    def rectfill x, y, w, h, pal_number = tweetcart_state.color
      r, g, b = pal[pal_number]
      abgr_hex = (255 << 24) + (b << 16) + (g << 8) + r
      h.times do |i|
        row_increment = (y + i) * 160
        $args.pixel_array(:pixels).pixels.fill(abgr_hex, x + row_increment, w)
      end
    end

    def circfill cx, cy, cr, pal_number = tweetcart_state.color
      r, g, b = pal[pal_number]
      abgr_hex = (255 << 24) + (b << 16) + (g << 8) + r

      x0 = cx
      y0 = cy
      radius = cr

      x = 0
      y = radius
      p = 1 - radius

      while x <= y
        rect_fill x0 - x, y0 + y, 2 * x, 1, pal_number
        rect_fill x0 - x, y0 - y, 2 * x, 1, pal_number
        rect_fill x0 - y, y0 + x, 2 * y, 1, pal_number
        rect_fill x0 - y, y0 - x, 2 * y, 1, pal_number

        x += 1
        if p < 0
          p += 2 * x + 1
        else
          y -= 1
          p += 2 * (x - y) + 1
        end
      end
    end
  end # end $top_level class
end # end TICK


=begin
wht  = [255] * 3
red  = [255, 0, 0]
blu  = [0, 130, 255]
purp = [150, 80, 255]

TICK {
  bg! 0

  slds << [0, 0, 3, 3, 0, 255, 0, 255]

  sld!     10, 10
  sld!     20, 20, 3, 2
  sld!     30, 30, 2, 2, red
  sld!     35, 35, blu

  slds!    40, 40

  slds!   [50, 50],
          [60, 60, purp],
          [70, 70, 10, 10, wht],
          [80, 80, 4, 4, 255, 0, 255]
}

$gtk.reset
=end

=begin
TICK {
  pixels!
  color 0
  circfill 10, 10, 5, 20
  rectfill 20, 10, 5
}

$gtk.reset
=end
