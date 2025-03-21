# game concept from: https://youtu.be/Tz-AinJGDIM

# This class encapsulates the logic of a button that pulses when clicked.
# It is used in the StartScene and GameOverScene classes.
class PulseButton
  # a block is passed into the constructor and is called when the button is clicked,
  # and after the pulse animation is complete
  def initialize rect, text, &on_click
    @rect = rect
    @text = text
    @on_click = on_click
    @pulse_animation_spline = [[0.0, 0.90, 1.0, 1.0], [1.0, 0.10, 0.0, 0.0]]
    @duration = 10
  end

  # the button is ticked every frame and check to see if the mouse
  # intersects the button's bounding box.
  # if it does, then pertinent information is stored in the @clicked_at variable
  # which is used to calculate the pulse animation
  def tick tick_count, mouse
    @tick_count = tick_count

    if @clicked_at && @clicked_at.elapsed_time > @duration
      @clicked_at = nil
      @on_click.call
    end

    return if !mouse.click
    return if !mouse.inside_rect? @rect
    @clicked_at = tick_count
  end

  # this function returns an array of primitives that can be rendered
  def prefab easing
    # calculate the percentage of the pulse animation that has completed
    # and use the percentage to compute the size and position of the button
    perc = if @clicked_at
             Easing.spline @clicked_at, @tick_count, @duration, @pulse_animation_spline
           else
             0
           end

    rect = { x: @rect.x - 50 * perc / 2,
             y: @rect.y - 50 * perc / 2,
             w: @rect.w + 50 * perc,
             h: @rect.h + 50 * perc }

    point = { x: @rect.x + @rect.w / 2, y: @rect.y + @rect.h / 2 }
    [
      { **rect, path: :pixel },
      { **point, text: @text, size_px: 32, anchor_x: 0.5, anchor_y: 0.5 }
    ]
  end
end

class Game
  attr_gtk

  def initialize args
    self.args = args
    @pulse_button ||= PulseButton.new({ x: 640 - 100, y: 360 - 50, w: 200, h: 100 }, 'Click Me!') do
      GTK.notify! "Animation complete and block invoked!"
    end
  end

  def tick
    @pulse_button.tick Kernel.tick_count, inputs.mouse
    outputs.primitives << @pulse_button.prefab(easing)
  end
end

def tick args
  $game ||= Game.new args
  $game.args = args
  $game.tick
end
