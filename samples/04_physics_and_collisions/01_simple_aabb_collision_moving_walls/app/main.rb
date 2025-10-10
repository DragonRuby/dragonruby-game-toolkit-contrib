class Game
  attr_gtk

  def initialize
    @dvd = {
      x: 640,
      y: 360,
      w: 64,
      h: 64,
      dx: 5,
      dy: 5,
      path: :solid,
      r: 80,
      g: 0,
      b: 0
    }

    @growth_speed = 10

    @blocks = {
      left: {
        x: 0,
        y: 0,
        target_x: 0,
        target_y: 0,
        dx: 0,
        dy: 0,
        w: 5,
        h: 720,
        target_w: 5,
        target_h: 720,
        dw: @growth_speed,
        dh: 0,
        path: :solid,
        r: 0,
        g: 0,
        b: 0
      },
      right: {
        x: 1275,
        y: 0,
        target_x: 1275,
        target_y: 0,
        dx: -@growth_speed,
        dy: 0,
        w: 5,
        h: 720,
        target_w: 5,
        target_h: 720,
        dw: @growth_speed,
        dh: 0,
        path: :solid,
        r: 0,
        g: 0,
        b: 0
      },
      top: {
        x: 0,
        y: 0,
        dx: 0,
        dy: 0,
        target_x: 0,
        target_y: 0,
        w: 1280,
        h: @growth_speed,
        target_w: 1280,
        target_h: 5,
        dw: 10,
        dh: 10,
        path: :solid,
        r: 0,
        g: 0,
        b: 0
      },
      bottom: {
        x: 0,
        y: 715,
        dx: 0,
        dy: -@growth_speed,
        target_x: 0,
        target_y: 715,
        w: 1280,
        h: 5,
        target_w: 1280,
        target_h: 5,
        dw: 10,
        dh: @growth_speed,
        path: :solid,
        r: 0,
        g: 0,
        b: 0
      },
    }
  end

  def align_x! target, to
    return if !to

    if target.x < to.x
      target.x = to.x - target.w
    else
      target.x = to.x + to.w
    end
  end

  def align_y! target, to
    return if !to

    if target.y > to.y
      target.y = to.y + to.h
    else
      target.y = to.y - target.h
    end
  end

  def tick
    outputs.background_color = [80, 80, 80]
    available_w = 1280 - (@blocks.left.target_w + @blocks.left.dw) - (@blocks.right.target_w + @blocks.right.dw)
    available_h = 720 - (@blocks.bottom.target_h + @blocks.bottom.dh) - (@blocks.top.target_h + @blocks.top.dh)

    if inputs.keyboard.key_down.j || inputs.keyboard.key_down.space
      @blocks.each do |_, block|
        if available_w > @dvd.w
          block.target_w += block.dw
          block.target_x += block.dx
        end

        if available_h > @dvd.h
          block.target_h += block.dh
          block.target_y += block.dy
        end
      end
    end

    @blocks.each do |_, block|
      block.w = block.w.lerp(block.target_w, 0.1)
      block.x = block.x.lerp(block.target_x, 0.1)
      collision = @blocks.values.find { |block| Geometry.intersect_rect?(@dvd, block) }
      align_x!(@dvd, collision)

      block.h = block.h.lerp(block.target_h, 0.1)
      block.y = block.y.lerp(block.target_y, 0.1)
      collision = @blocks.values.find { |block| Geometry.intersect_rect?(@dvd, block) }
      align_y!(@dvd, collision)
    end

    @dvd.x += @dvd.dx
    collision = @blocks.values.find { |block| Geometry.intersect_rect?(@dvd, block) }
    if collision
      align_x!(@dvd, collision)
      @dvd.dx = -@dvd.dx
    end

    @dvd.y += @dvd.dy
    collision = @blocks.values.find { |block| Geometry.intersect_rect?(@dvd, block) }
    if collision
      align_y!(@dvd, collision)
      @dvd.dy = -@dvd.dy
    end

    outputs.labels << { x: 640, y: 360, text: "Press J or Space to shrink the walls.", anchor_x: 0.5, anchor_y: 0.5, r: 255, g: 255, b: 255 }
    outputs.sprites << @dvd
    outputs.sprites << @blocks.values
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
