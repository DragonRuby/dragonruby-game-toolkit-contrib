# This is a simple example of how to create an RTS style game.
# The sample should be seen as a cursory starting point and a general approach to how one might structure a game like this.

# this is a helper function that generates the primitives needed to
# render a thick line between two points
class ThickLine
  def self.primitives(x:, y:, x2:, y2:, thickness: 3, r: 0, g: 0, b: 0, a: 255)
    line = { x: x, y: y, x2: x2, y2: y2 }
    line_length = Geometry.line_length line
    line_angle = Geometry.line_angle line
    perpendicular_angle = (line_angle + 90) % 360
    vec = perpendicular_angle.to_vector
    return { x: x - vec.x * (thickness / 2),
             y: y - vec.y * (thickness / 2) + 2,
             angle: line_angle,
             angle_anchor_x: 0,
             angle_anchor_y: 0,
             path: :solid,
             r: r, g: g, b: b, a: a,
             w: line_length,
             h: thickness }
  end
end

# This class represents the command center and holds the total number of minearls the player has collected.
class CommandCenter
  attr :id, :rect, :x, :y, :minerals

  # the command center has a fixed size of 64x64 and is anchored at its center. The minerals start at 0.
  def initialize(id:, x:, y:)
    @id = id
    @x = x
    @y = y
    @rect = Geometry.rect_props(x: x, y: y, w: 64, h: 64, anchor_x: 0.5, anchor_y: 0.5)
    @minerals = 0
  end

  # this is a simple method that returns the primitives needed to render the command center.
  def building_primitives
    @building_primitives ||= [
      @rect.merge(path: :solid, **DawnBringer::DARK_BLUE),
      Geometry.zoom_rect(rect: @rect, ratio: 0.8).merge(path: :solid, **DawnBringer::BLUE),
    ]
  end

  # this is a label primitive representing the amount of minerals the player has. It is anchored to the bottom center of the command center.
  def money_primitives
    { x: @rect.center,
      y: @rect.y + @rect.h,
      text: "$#{@minerals.to_sf}",
      anchor_x: 0.5,
      anchor_y: 0.0,
      r: 255,
      g: 255,
      b: 255,
      size_px: 26 }
  end

  # this method combines the building primitives and the money
  # primitives into a single array that can be rendered together.
  def primitives
    [building_primitives, money_primitives]
  end

  # this method increments the minerals by 1. meeples will call this
  # method when they return minerals to the command center.
  def increment_minerals!
    @minerals += 1
  end
end

# this class represents a mineral field that can be mined by the
# meeples. It has a fixed size of 32x32 and is anchored at its
# center. It also keeps track of when it was last mined to prevent it
# from being mined too quickly.
class MineralField
  attr :id, :rect, :x, :y, :last_mined_at

  def initialize(id:, x:, y:)
    @id = id
    @x = x
    @y = y
    @rect = Geometry.rect_props(x: x, y: y, w: 32, h: 32, anchor_x: 0.5, anchor_y: 0.5)
    @last_mined_at = 0
  end

  # this method is called by meeples when they mine the mineral
  # field. It updates the last mined time to the current tick count.
  def decrement_minerals!
    @last_mined_at = Kernel.tick_count
  end

  # this method returns the primitives needed to render the mineral field.
  def primitives
    @primitives ||= [
      @rect.merge(path: :solid, **DawnBringer::DARK_RED_BROWN),
      Geometry.zoom_rect(rect: @rect, ratio: 0.8).merge(path: :solid, **DawnBringer::BRIGHT_YELLOW),
    ]
  end
end

# this class represents the single unit type in this rts
# it has a target command center and a target mineral field (if it's
# assigned to collection duty). It also has a simple state machine to manage its actions.
class Meeple
  attr :id, :action, :action_at, :mineral_field, :command_center

  def initialize(id:, x:, y:, command_center:)
    @id = id
    @x = x
    @y = y
    @speed = 2
    @target_x = x
    @target_y = y

    # the action, and action at is used to manage the state of the
    # meeple and when it started that state. The action can be :idle,
    # :waypoint, :will_mine, :mining, :will_return_minerals, or
    # :returning_minerals.
    @action = :idle
    @action_at = 0
    @command_center = command_center
  end

  # helper method to return the current location of the meeple as a
  # hash with x and y keys.
  def location
    { x: @x, y: @y }
  end

  # this method is used to set the target location of the meeple. It
  # is called by the waypoint! and mine! methods to set the target
  # location for the meeple to move
  def move_to(x:, y:)
    @target_x = x
    @target_y = y
  end

  # this function is invoked when the player sends the meeple to an
  # arbitrary location, if this is called, then we clear out the
  # mineral_field target (since they are no longer collecting minerals)
  def waypoint!(x:, y:)
    @mineral_field = nil
    move_to(x: x, y: y)
    action! :waypoint
  end

  # this function is invoked when the player sends the meeple to mine a
  # mineral field. It sets the target location to the location of the
  # mineral field and sets the state to :will_mine.
  def mine!(mineral_field)
    move_to(x: mineral_field.x, y: mineral_field.y)
    @mineral_field = mineral_field
    action! :will_mine
  end

  def tick
    # this is the main tick method that controls the behavior of the meeple.

    # we first call the __move_to_location__! method to move the meeple
    # towards its target location (if it hasn't already reached it).
    __move_to_location__!

    # if the meeple has a target mineral field...
    if @mineral_field
      # if it's reached the mineral field and it's set to :will_mine,
      # and it's been more than 240 ticks since the mineral field was
      # last mined, we mine the mineral field and set the action to
      # :mining
      if reached_location? && @action == :will_mine && @mineral_field.last_mined_at.elapsed_time > 240
        # invoking decrement_minerals! on the mineral field will
        # update its last mined time to the current tick count, which
        # will prevent it from being mined again for another 240
        @mineral_field.decrement_minerals!
        action! :mining
      elsif @action == :mining && @action_at.elapsed_time == 120
        # after mining for 120 ticks, we set the target location to
        # the command center and set the action to
        # :will_return_minerals
        move_to(x: @command_center.x, y: @command_center.y)
        action! :will_return_minerals
      elsif @action == :will_return_minerals && reached_location?
        # once we reach the command center, we set the meeple to
        # returning_minerals
        action! :returning_minerals
      elsif @action == :returning_minerals && @action_at.elapsed_time == 120
        # after 120 ticks of returning minerals, we increment the
        # minerals in the command center
        # and set the meeple back to mining
        @command_center.increment_minerals!
        move_to(x: @mineral_field.x, y: @mineral_field.y)
        action! :will_mine
      end
    elsif reached_location? && @action == :waypoint
      # if the meeple has reached its target location and it isn't currently mining, we set it back to idle
      action! :idle
    end
  end

  def __move_to_location__!
    return if reached_location?

    diff_x = @target_x - @x
    diff_y = @target_y - @y

    vector = Geometry.angle({ x: @x, y: @y }, { x: @target_x, y: @target_y }).to_vector

    if diff_x.abs < @speed
      @x = @target_x
    else
      @x += vector.x * @speed
    end

    if diff_y.abs < @speed
      @y = @target_y
    else
      @y += vector.y * @speed
    end
  end

  # this is a helper method to manage setting the action and action at
  # the same time. Whenever we change the action, we want to reset the
  # action at time to the current tick count so that we can track how
  # long we've been in that action.
  def action! value
    return if @action == value
    @action = value
    @action_at = Kernel.tick_count
  end

  # this is a helper method to determine if the meeple has reached its target location. It returns true if the meeple's current x and y
  # coordinates are equal to the target x and y coordinates.
  def reached_location?
    @x == @target_x && @y == @target_y
  end

  # this represents the current rect of the meeple used for selection
  # by the player
  def rect
    Geometry.rect_props({ x: @x, y: @y, w: 16, h: 16, anchor_x: 0.5, anchor_y: 0.5 })
  end

  # this method returns the primitives needed to render the meeple as
  # if it were moving. A thick line is drawn from the meeple to its
  # target location and the meeple sprite bobs up and down as it
  # moves.
  def moving_primitives
    [
      ThickLine.primitives(x: @x, y: @y, x2: @target_x, y2: @target_y, thickness: 3, **DawnBringer::GRAY, a: 128),
      { x: @x, y: @y + Math.sin(Kernel.tick_count.fdiv(1.5) + @id) * 4, w: 16, h: 16, path: "sprites/meeple.png", anchor_x: 0.5, anchor_y: 0.5 }
    ]
  end

  def primitives
    # if the meeple's current action is :waypoint, :will_mine, or
    # :will_return_minerals, we want to render the meeple as if it
    # were moving. If the action is :mining or :returning_minerals, we
    # want to return `nil` (meaning the meeple will not be rendered),
    # if the action is :idle, we want to render the meeple standing still
    if @action == :waypoint
      moving_primitives
    elsif @action == :will_mine
      moving_primitives
    elsif @action == :mining
      nil
    elsif @action == :will_return_minerals
      moving_primitives
    elsif @action == :returning_minerals
      nil
    else
      { x: @x, y: @y, w: 16, h: 16, path: "sprites/meeple.png", anchor_x: 0.5, anchor_y: 0.5 }
    end
  end
end

# this is the core game where we put all the pieces together. It holds
# the command center, the mineral fields, and the meeples. It also
# manages the player input and the game state.
class Game
  attr_dr

  # this is a helper method to generate unique ids for the game objects.
  def id!
    @id ||= 0
    @id += 1
  end

  # this represents the current mouse selection rect and is used to
  # select meeples and mineral fields. It is a 48x48 rect centered on the mouse cursor.
  def selection_rect
    Geometry.rect_props(x: inputs.mouse.x,
                        y: inputs.mouse.y,
                        w: 48,
                        h: 48,
                        anchor_x: 0.5,
                        anchor_y: 0.5)
  end

  def initialize args
    # on game initialization, we set the command center to the center
    # of the map
    @command_center = CommandCenter.new(id: id!, x: 0, y: 0)

    # we generate 20 meeples at random locations on the map and assign
    # them the command center as their target for mining and returning
    # minerals.
    @meeples = 20.map do |i|
      Meeple.new(id: id!,
                 x: Numeric.rand(-600..600),
                 y: Numeric.rand(-300..300),
                 command_center: @command_center)
    end

    # to ensure that mineral fields don't overlap, we first generate
    # 12x24 locations, and remove any that are within 250 pixels of the command center.
    @available_mineral_field_locations = 12.map do |row|
      24.map do |col|
        Layout.rect(row: row, col: col, w: 1, h: 1).center
      end
    end
    .flatten
    .reject { |loc| Geometry.distance(loc, @command_center) < 250 }

    # we then shuffle the available locations and pop off the first 10
    # to be the locations of our mineral fields. We create a new
    # mineral field at each of those locations.
    tmp_available_locations = @available_mineral_field_locations.dup.shuffle

    @mineral_fields = 10.map do |i|
      location = tmp_available_locations.pop_front
      MineralField.new(id: id!,
                       x: location.x,
                       y: location.y)
    end
  end

  # this is the main tick method for the game
  def tick
    calc
    render
  end

  def calc
    # first tick all the meeples to update their state and positions based on their current actions and targets.
    @meeples.each(&:tick)

    # this represents the current hovered meeple by the mouse
    @hovered_meeple = @meeples.find_all do |m|
      Geometry.intersect_rect? selection_rect, m.rect
    end.sort_by { |m| Geometry.distance(inputs.mouse.point, m.location) }.first

    # this represents the current hovered mineral field by the mouse
    @hovered_mineral_field = @mineral_fields.find do |f|
      Geometry.intersect_rect? selection_rect, f.rect
    end

    # if the mouse is clicked and there is a selected meeple...
    if inputs.mouse.buttons.left.buffered_click && @selected_meeple
      # if the player clicks the selected meeple again, we deselect it
      if Geometry.intersect_rect?(inputs.mouse.rect, @selected_meeple.rect)
        @selected_meeple = nil
      else
        # otherwise we check to see if the player is currently
        # hovering over a mineral field, if so, then we send the
        # selected meeple to mine that mineral field. If not, then we
        # send the selected meeple to the location of the mouse click
        # as a waypoint.
        if @hovered_mineral_field
          @selected_meeple.mine!(@hovered_mineral_field)
          @selected_meeple = nil
        else
          @selected_meeple.waypoint!(x: inputs.mouse.x, y: inputs.mouse.y)
          @selected_meeple = nil
        end
      end
    elsif inputs.mouse.buttons.left.buffered_click && @hovered_meeple
      # if there is a click and there is no selected meeple but there
      # is a hovered meeple, we set the selected meeple to the hovered
      # meeple
      @selected_meeple = @hovered_meeple
    end

    # right clicking will deselect the currently selected meeple
    if inputs.mouse.key_up.right
      @selected_meeple = nil
    end
  end

  def render
    # first we set the background color to a dark gray
    outputs.background_color = [30, 30, 30]

    # this is a debug line that shows all the available locations for mineral fields as dark red brown squares.
    # outputs.primitives << @available_mineral_field_locations.map { |am| am.merge(w: 4, h: 4, path: :solid, **DawnBringer::DARK_RED_BROWN, anchor_x: 0.5, anchor_y: 0.5) }

    # render the command center
    outputs.primitives << @command_center.primitives

    # render the mineral fields
    outputs.primitives << @mineral_fields.map { |f| f.primitives }

    # render the meeples
    outputs.primitives << @meeples.map { |m| m.primitives }

    # if there is a selected meeple, then we want to render a green
    # rectangle around it to indicate that it is selected.
    if @selected_meeple
      outputs.primitives << { **Geometry.zoom_rect(rect: @selected_meeple.rect, ratio: 1.5),
                              path: :solid,
                              **DawnBringer::GREEN.merge(a: 128) }
    end

    # if there is a hovered meeple, then we want to render a yellow rectangle around it to indicate that it is being hovered over.
    if @hovered_meeple
      outputs.primitives << { **Geometry.zoom_rect(rect: @hovered_meeple.rect, ratio: 1.5),
                              path: :solid,
                              **DawnBringer::YELLOW.merge(a: 128) }
    end

    # if there is a selected meeple, we want to render a yellow
    # rectangle around the hovered mineral field to indicate that if
    # the player clicks, they will send the selected meeple to mine
    # that mineral field.
    if @selected_meeple && @hovered_mineral_field
      outputs.primitives << { **Geometry.zoom_rect(rect: @hovered_mineral_field.rect, ratio: 1.5),
                              path: :solid,
                              **DawnBringer::YELLOW.merge(a: 128) }
    end

    # render the mouse selection rect
    outputs.primitives << { x: selection_rect.x,
                            y: selection_rect.y,
                            w: selection_rect.w,
                            h: selection_rect.h,
                            path: "sprites/selection-rect.png",
                            **DawnBringer::WHITE.merge(a: 128) }

    # render instructions at the bottom
    outputs.primitives << { x: 0,
                            y: Grid.y + 16,
                            text: "click to select a meeple, then click to send it to a location or mineral field. right click to deselect.",
                            anchor_x: 0.5,
                            anchor_y: 0.5,
                            r: 255,
                            g: 255,
                            b: 255,
                            size_px: 16 }

    # this is a debug function that prints all the colors in the
    # DawnBringer palette as rectangles with their names and rgb
    # values. This is useful for reference when picking colors for the
    # game.
    # outputs.primitives << DawnBringer.debug_primitives
  end
end

def boot args
  args.state = {}
  Grid.origin_center!
end

def tick args
  $game ||= Game.new args
  $game.args = args
  $game.tick
end

def reset args
  $game = nil
end

module DawnBringer
  BLACK = { r: 20, g: 12, b: 28 }
  BLUE = { r: 89, g: 125, b: 206 }
  BLUE_GRAY = { r: 155, g: 173, b: 183 }
  BRIGHT_CYAN = { r: 95, g: 205, b: 228 }
  BRIGHT_GREEN = { r: 153, g: 229, b: 80 }
  BRIGHT_ORANGE = { r: 223, g: 113, b: 38 }
  BRIGHT_PURPLE = { r: 91, g: 110, b: 225 }
  BRIGHT_WHITE = { r: 232, g: 232, b: 232 }
  BRIGHT_YELLOW = { r: 251, g: 242, b: 54 }
  BROWN = { r: 133, g: 76, b: 48 }
  CHARCOAL = { r: 105, g: 106, b: 106 }
  CYAN = { r: 109, g: 194, b: 202 }
  DARK_BLUE = { r: 48, g: 52, b: 109 }
  DARK_BROWN_GRAY = { r: 89, g: 86, b: 82 }
  DARK_GRAY = { r: 78, g: 74, b: 78 }
  DARK_GREEN = { r: 52, g: 101, b: 36 }
  DARK_MAGENTA = { r: 69, g: 40, b: 60 }
  DARK_OLIVE = { r: 82, g: 75, b: 36 }
  DARK_PURPLE = { r: 68, g: 36, b: 52 }
  DARK_PURPLE_BLUE = { r: 34, g: 32, b: 52 }
  DARK_RED = { r: 172, g: 50, b: 50 }
  DARK_RED_BROWN = { r: 102, g: 57, b: 49 }
  DARK_TEAL = { r: 50, g: 60, b: 57 }
  GOLD = { r: 138, g: 111, b: 48 }
  GRAY = { r: 117, g: 113, b: 97 }
  GREEN = { r: 109, g: 170, b: 44 }
  LIGHT_BLUE = { r: 203, g: 219, b: 252 }
  LIGHT_GRAY = { r: 133, g: 149, b: 161 }
  LIGHT_GREEN_GRAY = { r: 196, g: 207, b: 161 }
  LIGHT_PEACH = { r: 238, g: 195, b: 154 }
  LIGHT_TAN = { r: 217, g: 160, b: 102 }
  MEDIUM_BROWN = { r: 143, g: 86, b: 59 }
  MEDIUM_GRAY = { r: 132, g: 126, b: 135 }
  MEDIUM_GREEN = { r: 106, g: 190, b: 48 }
  MEDIUM_PURPLE = { r: 63, g: 63, b: 116 }
  OLIVE_GREEN = { r: 75, g: 105, b: 47 }
  ORANGE = { r: 210, g: 125, b: 44 }
  PURE_BLACK = { r: 0, g: 0, b: 0 }
  PURE_WHITE = { r: 255, g: 255, b: 255 }
  PURPLE = { r: 118, g: 66, b: 138 }
  RED = { r: 208, g: 70, b: 72 }
  SKY_BLUE = { r: 99, g: 155, b: 255 }
  STEEL_BLUE = { r: 48, g: 96, b: 130 }
  TAN = { r: 210, g: 170, b: 153 }
  TEAL = { r: 55, g: 148, b: 110 }
  WHITE = { r: 222, g: 238, b: 214 }
  YELLOW = { r: 218, g: 212, b: 94 }

  def self.debug_primitives
    @primitives ||= constants.map_with_index do |c, i|
      row = i.fdiv(4).floor
      col = i % 4
      rect = Layout.rect(row: row, col: col * 2, w: 2, h: 1)
      [
        rect.merge(path: :solid, **const_get(c), desc: "color"),
        rect.center.merge(path: :solid, w: rect.w * 0.8, h: 32, r: 0, g: 0, b: 0, a: 128, anchor_x: 0.5, anchor_y: 0.5, desc: "background"),
        rect.center.merge(text: c.to_s.downcase, anchor_x: 0.5, anchor_y: 0.0, r: 255, g: 255, b: 255, size_px: 12, desc: "name"),
        rect.center.merge(text: "#{const_get(c).values}", anchor_x: 0.5, anchor_y: 1.0, r: 255, g: 255, b: 255, size_px: 12, desc: "rgb values"),
      ]
    end.flatten
  end
end

DR.reset
