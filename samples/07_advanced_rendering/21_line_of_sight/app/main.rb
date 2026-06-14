# This is an advanced example of line of sight / field of view / visibility calculation using a sweep line algorithm.
# Prerequisite knowledge:
# - Render targets: samples under ./samples/07_advanced_rendering (the sample apps
#                   are ordered from simpler to more complex, so start with
#                   the earlier ones if you haven't used render targets before)
#
# - Geometry apis: see docs under ./docs/api/geometry.md
#
# - Default blendmodes: sample: ./samples/07_advanced_rendering/13_lighting
#
# - Custom blendmodes: docs under ./docs/api/numeric.md#blendmodes
#                      sample: ./samples/07_advanced_rendering/20_rings
#
# IMPORTANT: Be sure to read license.txt
# Visibility and sweep algorithm derived from: https://www.redblobgames.com/articles/visibility/
# Original source code: https://www.redblobgames.com/articles/visibility/Visibility.hx

# First we define a custom blendmode that will be used to "punch
# holes" in the fog of war layer, allowing the visible areas to show
# through. This blendmode effectively multiplies the source color (the
# visible areas) with the destination color (the fog of war),
# resulting in the visible areas being subtracted from the fog of war.
HOLE_PUNCH_BLENDMODE = Numeric.compose_blendmode(BLENDFACTOR_ZERO,
                                                 BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
                                                 BLENDOPERATION_ADD,
                                                 BLENDFACTOR_ZERO,
                                                 BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
                                                 BLENDOPERATION_ADD)


# IMPORTANT: Be sure to read the write up at https://www.redblobgames.com/articles/visibility/

# This class implements the sweep line algorithm for calculating
# visible areas from a light source, given a set of line segments
# (walls). The `sweep` method takes in the line segments, the location
# of the light source, and an optional maximum angle to limit the
# field of view. It returns an array of triangles representing the
# visible areas. The algorithm works by sorting the endpoints of the
# line segments by their angle relative to the light source, and then
# sweeping through these endpoints to determine which segments are
# currently blocking the light and which areas are visible.
class Visibility
  class << self
    def sweep(lines, light_location, max_angle = 999.0)
      # represents the endpoint queue that needs to be processed
      endpoints = []

      # collection of triangles that represent the visible areas. Each
      # triangle is represented as a hash with keys :x, :y, :x2, :y2,
      # :x3, :y3
      results = []

      # this is the center point of the light source
      center = { x: light_location.x, y: light_location.y }

      # first we create a segment Hash which contains data in relation
      # to the light source, such as the angle of the endpoints and
      # whether the endpoint is the start or end of a segment.
      Array.compact(lines).each do |line|
        segment = new_segment(line, center)
        endpoints << segment.p1
        endpoints << segment.p2
      end

      # after segments are created, we sort the endpoints by their angle
      # from the center/light source.
      endpoints.sort! do |a, b|
        if a.angle > b.angle
          1
        elsif a.angle < b.angle
          -1
        elsif !a.begins_segment && b.begins_segment
          1
        elsif a.begins_segment && !b.begins_segment
          -1
        else
          0
        end
      end

      # this will represent the segments that are currently trying to resolve
      open_segments = []

      # we start our line sweep with an angle of 0
      current_sweep_angle = 0.0

      # we loop through the endpoints twice. The first pass is to find
      # the first endpoint that exceeds the max_angle (if max_angle is set to limit the field of view). The second pass is where we actually
      # build the triangles for the visible areas, and we break out of the loop once we reach the max_angle.
      2.times do |pass|
        # for each endpoint...
        endpoints.each do |endpoint|
          # if we're on the second pass and we've exceeded the
          # max_angle, we can stop processing further endpoints since
          # they won't be visible
          break if pass == 1 && endpoint.angle > max_angle

          # we keep track of the segment that is currently in front of
          # the light source before processing the current endpoint, so
          # that we can determine if the visible area has changed after
          # processing the endpoint
          segment_before = open_segments.empty? ? nil : open_segments[0]

          # if the endpoint is the start of a segment, we add it to the
          # open_segments collection in the correct position based on
          # its angle.
          if endpoint.begins_segment
            index = 0
            # we loop through the open_segments to find the correct
            # position to insert the new segment, based on whether it's
            # in front of or behind the other segments in relation to
            # the light source
            while index < open_segments.length && segment_in_front_of?(endpoint.segment, open_segments[index], center)
              index += 1
            end
            open_segments.insert(index, endpoint.segment)
          else
            # if the endpoint is the end of a segment, we remove the segment from the open_segments collection
            segment_id_to_remove = endpoint.segment.id
            open_segments.reject! { |seg| seg.id == segment_id_to_remove }
          end

          # after processing the endpoint, we check if the segment that
          # is currently in front of the light source has changed. If it
          # has, that means the visible area has changed, and we can
          # create a triangle representing the newly visible area
          # between the previous sweep angle and the current endpoint's
          # angle.
          segment_after = open_segments.empty? ? nil : open_segments[0]

          if segment_before != segment_after
            # if this is the second pass, we add a triangle to the results
            results << new_triangle(center, current_sweep_angle, endpoint.angle, segment_before) if pass == 1
            current_sweep_angle = endpoint.angle
          end
        end
      end

      # after processing all endpoints, we return the collection of triangles representing the visible areas
      # (compact removes nil values)
      Array.compact(results)
    end

    # function to determine if a point is to the left of a line segment,
    # in relation to the light source. This is used to determine the
    # order of segments in the open_segments collection.
    def left_of?(segment, point)
      Geometry.ray_test(point, segment.line) == :left
    end

    # function to perform linear interpolation between two points (used
    # in conjunction with the left_of? function to determine if a point
    # is to the left of a line segment by slightly offsetting the
    # endpoints of the segment)
    def vec2_lerp(a, b, f)
      {
        x: a.x.lerp(b.x, f),
        y: a.y.lerp(b.y, f)
      }
    end

    # function to determine if one segment is in front of another
    # segment in relation to the light source. This is used to sort the
    # segments in the open_segments collection.
    def segment_in_front_of?(a, b, relative_to)
      a1 = left_of?(a, vec2_lerp(b.p1, b.p2, 0.01))
      a2 = left_of?(a, vec2_lerp(b.p2, b.p1, 0.01))
      a3 = left_of?(a, relative_to)
      b1 = left_of?(b, vec2_lerp(a.p1, a.p2, 0.01))
      b2 = left_of?(b, vec2_lerp(a.p2, a.p1, 0.01))
      b3 = left_of?(b, relative_to)

      return true if b1 == b2 && b2 != b3
      return true if a1 == a2 && a2 == a3
      return false if a1 == a2 && a2 != a3
      return false if b1 == b2 && b2 == b3

      false
    end

    def line_intersection(p1, p2, p3, p4)
      line1 = Geometry.points_to_line(p1, p2)
      line2 = Geometry.points_to_line(p3, p4)
      Geometry.ray_intersect(line1, line2)
    end

    # this function creates a segment Hash from a line segment, and
    # calculates the angle of the endpoints and their distance from the
    # light source. The segment Hash contains the original line, the two
    # endpoints (p1 and p2), and the distance from the light source
    # (d). The endpoints also contain information about whether they are
    # the start or end of the segment, which is used in the sweep
    # algorithm.
    def new_segment(line, relative_to)
      segment = { id: DR.create_uuid, p1: nil, p2: nil, d: 0.0 }

      p1 = new_endpoint(line.x, line.y, segment)
      p2 = new_endpoint(line.x2, line.y2, segment)

      segment.p1 = p1
      segment.p2 = p2
      segment.line = line

      segment_midpoint = Geometry.line_midpoint(segment.line)
      segment.d = Geometry.distance_squared(relative_to, segment_midpoint)

      segment.p1.angle = Geometry.angle(relative_to, segment.p1)
      segment.p2.angle = Geometry.angle(relative_to, segment.p2)

      turn_direction = Geometry.angle_turn_direction(segment.p1.angle, segment.p2.angle)
      segment.p1.begins_segment = turn_direction > 0
      segment.p2.begins_segment = !segment.p1.begins_segment

      segment
    end

    # this function creates a triangle Hash representing a visible area,
    # given the origin of the light source, the angles of the two
    # endpoints that define the visible area, and the segment that is
    # currently blocking the light (if any). The triangle is represented
    # as a Hash with keys :x, :y, :x2, :y2, :x3, :y3, where (:x, :y) is
    # the origin of the light source, (:x2, :y2) is the intersection
    # point of the blocking segment with the ray from the light source
    # at angle1, and (:x3, :y3) is the intersection point of the
    # blocking segment with the ray from the light source at angle2. If
    # there is no blocking segment, then (:x2, :y2) and (:x3, :y3) are
    # calculated as points far away in the direction of angle1 and
    # angle2.
    def new_triangle(origin, angle1, angle2, segment)
      p1 = origin
      p2 = { x: origin.x + angle1.vector_x, y: origin.y + angle1.vector_y }
      p3 = { x: 0.0, y: 0.0 }
      p4 = { x: 0.0, y: 0.0 }

      if segment
        p3.x = segment.p1.x
        p3.y = segment.p1.y
        p4.x = segment.p2.x
        p4.y = segment.p2.y
      else
        p3.x = origin.x + angle1.vector_x * 1280
        p3.y = origin.y + angle1.vector_y * 1280
        p4.x = origin.x + angle2.vector_x * 1280
        p4.y = origin.y + angle2.vector_y * 1280
      end

      p_begin = line_intersection(p3, p4, p1, p2)

      p2.x = origin.x + angle2.vector_x
      p2.y = origin.y + angle2.vector_y

      p_end = line_intersection(p3, p4, p1, p2)

      return nil if !p_begin || !p_end  # Skip if lines are parallel

      {
        x: origin.x,
        y: origin.y,
        x2: p_begin.x,
        y2: p_begin.y,
        x3: p_end.x,
        y3: p_end.y,
      }
    end

    # this function creates an endpoint Hash for a given x, y coordinate
    # and segment. The endpoint Hash contains the x and y coordinates,
    # the angle from the light source (which is calculated later), a
    # reference to the segment it belongs to, and a boolean indicating
    # whether it is the start of the segment.
    def new_endpoint(x, y, segment)
      {
        x: x,
        y: y,
        angle: 0.0,
        segment: segment,
        begins_segment: false,
      }
    end
  end
end

# This is the main game class / entry point
class Game
  attr_dr

  def initialize
    # iVar tracks the last time the mouse was used
    # (if the mouse has moved or is dragging, then we are in "edit mode")
    @edit_wall_last_activated_at = 0

    # load the walls from the data/walls.txt file which is a csv of
    # x,y,w,h for each wall rectangle. We also add the boundary walls
    # around the edges of the screen. Each wall also has a "lines"
    # property which is an array of line segments representing the
    # edges of the wall, which is used in the visibility calculations.
    @walls = load_walls.map { |w| w.merge! lines: Geometry.rect_to_lines(w) }

    # player's start location and vision radius. Increase or decrease
    # the vision radius to see how it affects the visible areas.
    @player = { x: 640, y: 192, w: 32, h: 32, vision_radius: 512 }

    # this holds the results of the visibility calculations
    @visible_areas = []
    @sweep_complete = false

    # this is a grid of rectangles that we use for editing walls
    # (supports the snapping to a 16x16 tiled grid).
    @wall_grid = 80.flat_map do |x_i|
      45.map do |y_i|
        Geometry.rect_props x: x_i * 16, y: y_i * 16, w: 16, h: 16
      end
    end
  end

  # main tick methods
  def tick
    tick_edit_mode
    move_player
    process_visibility_if_needed
    render
  end

  # helper function to calculate the center point of the player
  def player_center
    { x: @player.x + @player.w / 2, y: @player.y + @player.h / 2 }
  end

  # visibility is recalculated if the player moves
  def process_visibility_if_needed
    return if @sweep_complete

    # we use a rect to get a rough set of walls that are within the
    # player's vision radius, and then we pass the line segments of
    # those walls to the sweep algorithm to get the visible areas.
    vision_rect = { **player_center, w: @player.vision_radius * 2, h: @player.vision_radius * 2, anchor_x: 0.5, anchor_y: 0.5 }
    lines_within_vision_radius = Geometry.find_all_intersect_rect(vision_rect, @walls)
                                         .flat_map { |w| w.lines }

    # this is the main invocation of the sweep line algorithm.
    @visible_areas = Visibility.sweep(lines_within_vision_radius, player_center)

    # set the sweep_complete flag to true so that we don't recalculate
    # visibility until the player moves again
    @sweep_complete = true
  end

  def edit_mode_active?
    # helper function to determine if we're in "edit mode" based on
    # the last time "edit mode" was activated (by mouse movement or dragging).
    @edit_wall_last_activated_at.elapsed_time < 60
  end

  def tick_edit_mode
    # if the mouse has moved or is dragging, we update the last
    # activated time for edit mode, which keeps us in edit mode for 1
    # second after the last mouse movement or drag.
    if inputs.mouse.moved || inputs.mouse.buttons.left.buffered_held
      @edit_wall_last_activated_at = Kernel.tick_count
    end

    return if !edit_mode_active?

    # clicking represents a delete, holding a dragging represents
    # creating a wall. We use inputs.mouse.buttons.left.buffered_held
    # which handles the case where the player clicks and holds without
    # moving the mouse, which would not trigger
    # inputs.mouse.moved. This allows for creating walls by clicking
    # and holding without needing to move the mouse.
    if inputs.mouse.buttons.left.buffered_held
      @edit_wall_current_point = Geometry.find_intersect_rect({ x: inputs.mouse.x, y: inputs.mouse.y, w: 2, h: 2 }, @wall_grid)
    end

    # if a click was performed (as opposed to a drag), then check if a
    # wall was clicked and delete it from the walls and save the
    # updated walls to the data/walls.txt file.
    if inputs.mouse.buttons.left.buffered_click
      wall_to_delete = Geometry.find_intersect_rect({ x: inputs.mouse.x, y: inputs.mouse.y, w: 2, h: 2 }, @walls)
      if wall_to_delete
        @walls.delete(wall_to_delete)
        save_walls
      end
    elsif inputs.mouse.buttons.left.buffered_held && !@edit_wall_start_point
      # if dragging has just started, we set the start point for the
      # new wall. The current point will be updated as the mouse
      # moves, and when the mouse button is released, we will create a
      # new wall from the start point to the current point.
      @edit_wall_start_point = @edit_wall_current_point
    elsif inputs.mouse.key_up.left && @edit_wall_start_point && @edit_wall_current_point
      # if dragging has just ended, we create a new wall from the
      # start point to the current point, but only if the resulting
      # wall has a width and height greater than 0 (to prevent
      # creating walls from accidental clicks or very small drags). We
      # then save the updated walls to the data/walls.txt file.
      rect_to_add = edit_wall_current_rect
      if rect_to_add && rect_to_add.w > 0 && rect_to_add.h > 0
        @walls << rect_to_add.merge(lines: Geometry.rect_to_lines(rect_to_add))
      end
      @edit_wall_start_point = nil
      @edit_wall_current_point = nil
      save_walls
    end
  end

  # helper function returns a rectangle representing the wall being currently edited
  def edit_wall_current_rect
    if @edit_wall_start_point
      point_1 = @edit_wall_start_point.center
      point_2 = @edit_wall_current_point.center
      w = (point_1.x - point_2.x).abs
      h = (point_1.y - point_2.y).abs
      if w < 16
        w = 16
        point_2 = { x: point_1.x + 16, y: point_2.y }
      end

      if h < 16
        h = 16
        point_2 = { x: point_2.x, y: point_1.y + 16 }
      end

      {
        x: [point_1.x, point_2.x].min,
        y: [point_1.y, point_2.y].min,
        w: w,
        h: h
      }
    else
      nil
    end
  end

  # this function handles player movement based on keyboard input.
  def move_player
    speed = 3
    dx = inputs.keyboard.left_right * speed
    dy = inputs.keyboard.up_down * speed

    if dx != 0 || dy != 0
      @player.x += dx
      @player.y += dy
      # reset the visibility calculations so that they will be
      # recalculated on the next tick, since the player has moved and
      # the visible areas may have changed.
      reset_visibility
    end
  end

  def render
    # set the top level background color to black so that blending
    # with the fog of war layer works correctly (the visible areas
    # will be blended with the black background to punch holes in the
    # fog of war).
    outputs.background_color = [0, 0, 0]

    # ==============================================================
    # CONSTRUCTION OF THE MAIN SCENE RENDER TARGET
    # ==============================================================
    # this is the main scene layer that is rendered without lighting
    # or fog of war, which contains the walls and the player.
    outputs[:scene].set background_color: [30, 30, 30, 255], w: 1280, h: 720

    # render the walls with a slightly larger rectangle behind them in a different color to create a "border" effect
    outputs[:scene].primitives << @walls.map do |wall|
        { x: wall.x - 4,
          y: wall.y - 4,
          w: wall.w + 8,
          h: wall.h + 8,
          r: 0,
          g: 128,
          b: 80,
          path: :solid }
    end

    # render the a sprite that represents the player's light.
    outputs[:scene].primitives << { **player_center,
                                     path: "sprites/mask.png",
                                     w: @player.vision_radius * 2,
                                     h: @player.vision_radius * 2,
                                     anchor_x: 0.5,
                                     anchor_y: 0.5,
                                     a: 64,
                                     r: 255,
                                     g: 80,
                                     b: 128 }

    # render the player as a solid rectangle on top of the light sprite
    outputs[:scene].primitives << { **@player, path: :solid, r: 255, g: 80, b: 128 }

    # render a black overlay on top of the wall, the "inside" of the
    # wall is never visible, so we can just render a solid black
    # rectangle to cover it up
    outputs[:scene].primitives << @walls.map do |wall|
        { x: wall.x,
          y: wall.y,
          w: wall.w,
          h: wall.h,
          r: 0,
          g: 0,
          b: 0,
          path: :solid }
    end

    # ==============================================================
    # CONSTRUCTION OF THE FOG OF WAR "LIGHTS" USING CUSTOM BLENDMODES
    # ==============================================================

    # first we set the background to transparent so that the textures
    # below the fog of war will show through when we add the clipping holes for the visible areas.
    outputs[:fog_of_war_lights].set w: 1280, h: 720, background_color: [0, 0, 0, 0]

    # render the triangles to the render target
    outputs[:fog_of_war_lights].primitives << @visible_areas

    # render the fog of war and apply the "fog of war lights" texture
    outputs[:fog_of_war].set w: 1280, h: 720, background_color: [0, 0, 0, 0]

    # if we're in "edit mode", then lighten the fog of war to make it
    # easier to see the walls and edit them. Otherwise, render the fog
    # of war as fully opaque.
    if edit_mode_active?
      outputs[:fog_of_war].primitives << { x: 0, y: 0, w: 1280, h: 720, path: :solid, r: 0, g: 0, b: 0, a: 128 }
    else
      outputs[:fog_of_war].primitives << { x: 0, y: 0, w: 1280, h: 720, path: :solid, r: 0, g: 0, b: 0, a: 255 }
    end

    # This is where the holepunch blendmode is applied to punch holes
    # in the fog of war based on the visible areas rendered to the
    # :fog_of_war_lights render target.
    outputs[:fog_of_war].primitives << { x: 0,
                                         y: 0,
                                         w: 1280,
                                         h: 720,
                                         path: :fog_of_war_lights,
                                         blendmode: HOLE_PUNCH_BLENDMODE }

    # ===================================================================
    # RENDER OF GLOBAL LIGHTS
    # ===================================================================
    # background color of the render target is set to transparent
    outputs[:lights].set w: 1280, h: 720, background_color: [0, 0, 0, 0]

    # render the mask to the lights render target, this will be
    # blended with the main scene to give the illusion of a
    # feathered/dimming light around the player.
    outputs[:lights].primitives << { **player_center,
                                     path: "sprites/mask.png",
                                     w: @player.vision_radius * 2,
                                     h: @player.vision_radius * 2,
                                     anchor_x: 0.5,
                                     anchor_y: 0.5,
                                     a: 255,
                                     r: 0,
                                     g: 0,
                                     b: 0 }

    # ================================================================
    # FINAL COMPOSITION OF THE MAIN SCENE WITH LIGHTING AND FOG OF WAR
    # =================================================================

    outputs[:lighted_scene].set w: 1280, h: 720, background_color: [0, 0, 0, 255]

    # lights are placed first with a blend mode of 0 (no blending)
    outputs[:lighted_scene].primitives << { x: 0, y: 0, w: 1280, h: 720, path: :lights, blendmode: 0 }

    # the main scene is blended on top of the lights with a blend mode
    # of 2 (additive blending) which causes the colors of the scene to
    # be added to the colors of the lights, creating the effect of the
    # light brightening the scene. The areas of the scene that are
    # under the light will be brightened, while the areas outside of
    # the light will remain dark.
    outputs[:lighted_scene].primitives << { x: 0, y: 0, w: 1280, h: 720, path: :scene, blendmode: 2 }

    # finally, the fog of war is rendered on top of everythinng
    outputs[:lighted_scene].primitives << { x: 0, y: 0, w: 1280, h: 720, path: :fog_of_war }

    # render this final scene to the screen
    outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :lighted_scene }

    # NOTE: uncomment these lines to see what the scene looks like
    # without lighting or fog of war
    # outputs[:scene].primitives << @visible_areas.map { |t| t.merge(a: 128) }
    # outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :scene }

    # =======================================================================
    # RENDER THE UI AND EDIT MODE OVERLAY
    # =======================================================================
    outputs.primitives << { x: 0, y: 0, w: 1280, h: 32, path: :solid, r: 0, g: 0, b: 0 }
    outputs.primitives << { x: 640, y: 16, text: "Click to delete a wall, drag to create a wall. WASD or arrow keys to move.", anchor_x: 0.5, anchor_y: 0.5, r: 255, g: 255, b: 255 }

    if edit_mode_active? && edit_wall_current_rect
      outputs.primitives << edit_wall_current_rect.merge(path: :solid, r: 255, g: 0, b: 0)
    end
  end

  # helper functions to load and save walls from the data/walls.txt file.
  def load_walls
    boundary_walls = [
      { x: 0, y: 0, w: 1280, h: 16 },
      { x: 0, y: 0, w: 16, h: 720 },
      { x: 0, y: 704, w: 1280, h: 16 },
      { x: 1264, y: 0, w: 16, h: 720 }
    ]
    contents = File.read "data/walls.txt"
    return boundary_walls if !contents

    contents.split("\n").map do |line|
      x, y, w, h = line.split(",").map(&:to_f)
      { x: x, y: y, w: w, h: h }
    end.reject { |wall| wall.w == 0 || wall.h == 0 } + boundary_walls
  end

  # helper function to save the current walls to the data/walls.txt file in a csv format of x,y,w,h for each wall.
  def save_walls
    lines = @walls.map do |wall|
      "#{wall.x},#{wall.y},#{wall.w},#{wall.h}"
    end
    File.write "data/walls.txt", lines.join("\n")
    reset_visibility
  end

  def reset_visibility
    @visible_areas = []
    @sweep_complete = false
  end
end

def boot(args)
  args.state = {}
end

def tick(args)
  $game ||= Game.new
  $game.args = args
  $game.tick
end

def reset(args)
  $game = nil
end

DR.reset
