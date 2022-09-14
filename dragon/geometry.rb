# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# geometry.rb has been released under MIT (*only this file*).

module GTK
  module Geometry
    def self.rotate_point point, angle, around = nil
      s = Math.sin angle.to_radians
      c = Math.cos angle.to_radians
      px = point.x
      py = point.y
      cx = 0
      cy = 0
      if around
        cx = around.x
        cy = around.y
      end

      point.merge(x: ((px - cx) * c - (py - cy) * s) + cx,
                  y: ((px - cx) * s + (py - cy) * c) + cy)
    end

    # Returns f(t) for a cubic Bezier curve.
    def self.cubic_bezier t, a, b, c, d
      s  = 1 - t
      s0 = 1
      s1 = s
      s2 = s * s
      s3 = s * s * s

      t0 = 1
      t1 = t
      t2 = t * t
      t3 = t * t * t

      1 * s3 * t0 * a +
      3 * s2 * t1 * b +
      3 * s1 * t2 * c +
      1 * s0 * t3 * d
    end

    # Returns true if a primitive's rectangle is entirely inside another primitive's rectangle.
    # @gtk
    def inside_rect? outer, tolerance = 0.0
      Geometry.inside_rect? self, outer, tolerance
    end

    def intersects_rect? *args
      Geometry.intersects_rect?(*args)
    end

    def scale_rect_extended percentage_x: percentage_x,
                            percentage_y: percentage_y,
                            anchor_x: anchor_x,
                            anchor_y: anchor_y

      Geometry.scale_rect_extended self,
                                   percentage_x: percentage_x,
                                   percentage_y: percentage_y,
                                   anchor_x: anchor_x,
                                   anchor_y: anchor_y
    end

    # Scales a primitive rect by a percentage.
    # @gtk
    def scale_rect percentage, *anchors
      Geometry.scale_rect self, percentage, *anchors
    end

    # Returns the angle from one primitive to another primitive.
    # @gtk
    def angle_to other_point
      Geometry.angle_to self, other_point
    end

    # Returns the angle to one primitive from another primitive.
    # @gtk
    def angle_from other_point
      Geometry.angle_from self, other_point
    end

    # Returns true if a primitive is within a circle specified by the circle's center and radius.
    # @gtk
    def point_inside_circle? circle_center_point, radius
      Geometry.point_inside_circle? self, circle_center_point, radius
    end

    def self.center_inside_rect rect, other_rect
      offset_x = (other_rect.w - rect.w).half
      offset_y = (other_rect.h - rect.h).half
      new_rect = rect.shift_rect(0, 0)
      new_rect.x = other_rect.x + offset_x
      new_rect.y = other_rect.y + offset_y
      new_rect
    rescue Exception => e
      raise e, <<-S
* ERROR:
center_inside_rect for self #{self} and other_rect #{other_rect}.\n#{e}.
S
    end

    def center_inside_rect other_rect
      Geometry.center_inside_rect self, other_rect
    end

    def self.center_inside_rect_x rect, other_rect
      offset_x   = (other_rect.w - rect.w).half
      new_rect   = rect.shift_rect(0, 0)
      new_rect.x = other_rect.x + offset_x
      new_rect.y = other_rect.y
      new_rect
    rescue Exception => e
      raise e, <<-S
* ERROR:
center_inside_rect_x for self #{self} and other_rect #{other_rect}.\n#{e}.
S
    end

    def center_inside_rect_x other_rect
      Geometry.center_inside_rect_x self, other_rect
    end

    def self.center_inside_rect_y rect, other_rect
      offset_y = (other_rect.h - rect.h).half
      new_rect = rect.shift_rect(0, 0)
      new_rect.x = other_rect.x
      new_rect.y = other_rect.y + offset_y
      new_rect
    rescue Exception => e
      raise e, <<-S
* ERROR:
center_inside_rect_y for self #{self} and other_rect #{other_rect}.\n#{e}.
S
    end

    def center_inside_rect_y other_rect
      Geometry.center_inside_rect_y self, other_rect
    end


    # Returns a primitive that is anchored/repositioned based off its rectangle.
    # @gtk
    def anchor_rect anchor_x, anchor_y
      current_w = self.w
      current_h = self.h
      delta_x = -1 * (anchor_x * current_w)
      delta_y = -1 * (anchor_y * current_h)
      self.shift_rect(delta_x, delta_y)
    end

    def angle_given_point other_point
      raise ":angle_given_point has been deprecated use :angle_from instead."
    end

    # @gtk
    def self.shift_line line, x, y
      if line.is_a?(Array) || line.is_a?(Hash)
        new_line = line.dup
        new_line.x  += x
        new_line.x2 += x
        new_line.y  += y
        new_line.y2 += y
        new_line
      else
        raise "shift_line for #{line} is not supported."
      end
    end

    def self.intersects_rect? *args
      raise <<-S
intersects_rect? (with an \"s\") has been deprecated.
Use intersect_rect? instead (remove the \"s\").

* NOTE:
Ruby's naming convention is to *never* include the \"s\" for
interrogative method names (methods that end with a ?). It
doesn't sound grammatically correct, but that has been the
rule for a long time (and why intersects_rect? has been deprecated).

S
    end

    # @gtk
    def self.line_y_intercept line, replace_infinity: nil
      line.y - line_slope(line, replace_infinity: replace_infinity) * line.x
    rescue Exception => e
raise <<-S
* ERROR: ~Geometry::line_y_intercept~
The following exception was thrown for line: #{line}
#{e}

Consider passing in ~replace_infinity: VALUE~ to handle for vertical lines.
S
    end

    # @gtk
    def self.angle_between_lines line_one, line_two, replace_infinity: nil
      m_line_one = line_slope line_one, replace_infinity: replace_infinity
      m_line_two = line_slope line_two, replace_infinity: replace_infinity
      Math.atan((m_line_one - m_line_two) / (1 + m_line_two * m_line_one)).to_degrees
    end

    # @gtk
    def self.line_slope line, replace_infinity: nil
      if line.is_a? Hash
        # check to see if replace_inifinity exists on the hash
        # handles for if the dev does:
        #   line_slope(x: 10, y: 10, x2: 100, y2: 100, replace_infinity: 10)
        # instead of
        #   line_slope({ x: 10, y: 10, x2: 100, y2: 100 }, replace_infinity: 10)
        replace_infinity ||= line[:replace_infinity]
      end

      if line.y == line.y2 && line.x == line.x2
        raise <<-S
* ERROR: ~Geometry::line_slope~
  I was given a line with zero length and can't compute its slope:
  #{line}
S
      elsif line.y == line.y2
        return 0
      elsif line.x == line.x2
        return nil if !replace_infinity
        if line.y2 < line.y
          return replace_infinity * -1
        else
          return replace_infinity
        end
      end

      (line.y2 - line.y).fdiv(line.x2 - line.x)
                        .replace_infinity(replace_infinity)
    end

    def self.line_rise_run line
      rise = (line.y2 - line.y).to_f
      run  = (line.x2 - line.x).to_f
      if rise.abs > run.abs && rise != 0
        rise = rise.fdiv rise.abs
        run = run.fdiv rise.abs
      elsif run.abs > rise.abs && run != 0
        rise = rise.fdiv run.abs
        run = run.fdiv run.abs
      else
        rise = rise / rise.abs if rise != 0
        run = run / run.abs if run != 0
      end
      return { x: run , y: rise }
    end

    # @gtk
    def self.ray_test point, line
      slope = (line.y2 - line.y).fdiv(line.x2 - line.x)

      x  = line.x
      y  = line.y
      x2 = line.x2
      y2 = line.y2

      if x2 < x
        x, x2 = x2, x
        y, y2 = y2, y
      end

      r = ((x2 - x) * (point.y - y) - (point.x -  x) * (y2 - y))

      if r == 0
        return :on
      elsif r < 0
        return :right if slope >= 0
        return :left
      elsif r > 0
        return :left if slope >= 0
        return :right
      end
    end

    # @gtk
    def self.line_rect line, min_w: 0, min_h: 0
      if min_w < 0 || min_h < 0
      raise <<-S
* ERROR: ~Geometry::line_rect~
  ~min_w~ and ~min_h~ must be greater than min
  line:  #{line}
  min_w: #{min_w}
  min_h: #{min_h}
S
      end

      if line.x > line.x2
        x  = line.x2
        x2 = line.x
      else
        x  = line.x
        x2 = line.x2
      end

      if line.y > line.y2
        y  = line.y2
        y2 = line.y
      else
        y  = line.y
        y2 = line.y2
      end

      w = x2 - x
      h = y2 - y

      if w < min_w
        w  = min_w
        x -= min_w / 2
      end

      if h < min_h
        h  = min_h
        y -= min_h / 2
      end

      { x: x, y: y, w: w, h: h }
    end

    # @gtk
    def self.line_intersect line_one, line_two, replace_infinity: nil
      x1 = line_one.x
      y1 = line_one.y
      x2 = line_one.x2
      y2 = line_one.y2

      x3 = line_two.x
      y3 = line_two.y
      x4 = line_two.x2
      y4 = line_two.y2

      x1x2 = x1 - x2
      y1y2 = y1 - y2
      x1x3 = x1 - x3
      y1y3 = y1 - y3
      x3x4 = x3 - x4
      y3y4 = y3 - y4

      d =  x1x2 * y3y4 - y1y2 * x3x4;

      return nil if d == 0

      t = (x1x3 * y3y4 - y1y3 * x3x4) / d
      u = -(x1x2 * y1y3 - y1y2 * x1x3) / d

      {
        x: x1 + t * (x2 - x1),
        y: y1 + t * (y2 - y1)
      }
    rescue Exception => e
raise <<-S
* ERROR: ~Geometry::line_intersect~
The following exception was thrown for line_one: #{line_one}, line_two: #{line_two}
#{e}

Consider passing in ~replace_infinity: VALUE~ to handle for vertical lines.
S
    end

    def self.contract_intersect_rect?
      [:x, :y, :w, :h]
    end

    # @gtk
    def self.to_square size, x, y, anchor_x = 0.5, anchor_y = nil
      anchor_y ||= anchor_x
      x = x.shift_left(size * anchor_x)
      y = y.shift_down(size * anchor_y)
      [x, y, size, size]
    rescue Exception => e
      raise e, ":to_square failed for size: #{size} x: #{x} y: #{y} anchor_x: #{anchor_x} anchor_y: #{anchor_y}.\n#{e}"
    end

    # @gtk
    def self.distance point_one, point_two
      Math.sqrt((point_two.x - point_one.x)**2 + (point_two.y - point_one.y)**2)
    rescue Exception => e
      raise e, ":distance failed for point_one: #{point_one} point_two #{point_two}.\n#{e}"
    end

    # @gtk
    def self.angle_from start_point, end_point
      d_y = end_point.y - start_point.y
      d_x = end_point.x - start_point.x
      Math::PI.+(Math.atan2(d_y, d_x)).to_degrees
    rescue Exception => e
      raise e, ":angle_from failed for start_point: #{start_point} end_point: #{end_point}.\n#{e}"
    end

    # @gtk
    def self.angle_to start_point, end_point
      angle_from end_point, start_point
    rescue Exception => e
      raise e, ":angle_to failed for start_point: #{start_point} end_point: #{end_point}.\n#{e}"
    end

    # @gtk
    def self.point_inside_circle? point, circle_center_point, radius
      (point.x - circle_center_point.x) ** 2 + (point.y - circle_center_point.y) ** 2 < radius ** 2
    rescue Exception => e
      raise e, ":point_inside_circle? failed for point: #{point} circle_center_point: #{circle_center_point} radius: #{radius}.\n#{e}"
    end

    # @gtk
    def self.inside_rect? inner_rect, outer_rect, tolerance = 0.0
      return nil if !inner_rect
      return nil if !outer_rect

      inner_rect.x     + tolerance >= outer_rect.x     - tolerance &&
      (inner_rect.x + inner_rect.w) - tolerance <= (outer_rect.x + outer_rect.w) + tolerance &&
      inner_rect.y     + tolerance >= outer_rect.y     - tolerance &&
      (inner_rect.y + inner_rect.h) - tolerance <= (outer_rect.y + outer_rect.h) + tolerance
    rescue Exception => e
      raise e, ":inside_rect? failed for inner_rect: #{inner_rect} outer_rect: #{outer_rect}.\n#{e}"
    end

    # @gtk
    def self.scale_rect_extended rect,
                                 percentage_x: percentage_x,
                                 percentage_y: percentage_y,
                                 anchor_x: anchor_x,
                                 anchor_y: anchor_y
      anchor_x ||= 0.0
      anchor_y ||= 0.0
      percentage_x ||= 1.0
      percentage_y ||= 1.0
      new_w = rect.w * percentage_x
      new_h = rect.h * percentage_y
      new_x = rect.x + (rect.w - new_w) * anchor_x
      new_y = rect.y + (rect.h - new_h) * anchor_y
      if rect.is_a? Array
        return [
          new_x,
          new_y,
          new_w,
          new_h,
          *rect[4..-1]
        ]
      elsif rect.is_a? Hash
        return rect.merge(x: new_x, y: new_y, w: new_w, h: new_h)
      else
        rect.x = new_x
        rect.y = new_y
        rect.w = new_w
        rect.h = new_h
        return rect
      end
    rescue Exception => e
      raise e, ":scale_rect_extended failed for rect: #{rect} percentage_x: #{percentage_x} percentage_y: #{percentage_y} anchors_x: #{anchor_x} anchor_y: #{anchor_y}.\n#{e}"
    end

    # @gtk
    def self.scale_rect rect, percentage, *anchors
      anchor_x, anchor_y = *anchors.flatten
      anchor_x ||= 0
      anchor_y ||= anchor_x
      Geometry.scale_rect_extended rect,
                                   percentage_x: percentage,
                                   percentage_y: percentage,
                                   anchor_x: anchor_x,
                                   anchor_y: anchor_y
    rescue Exception => e
      raise e, ":scale_rect failed for rect: #{rect} percentage: #{percentage} anchors [#{anchor_x} (x), #{anchor_y} (y)].\n#{e}"
    end

    def self.rect_to_line rect
      l = rect.to_hash.line
      l.merge(x2: l.x + l.w - 1,
              y2: l.y + l.h)
    end

    def self.rect_center_point rect
      { x: rect.x + rect.w.half, y: rect.y + rect.h.half }
    end

    def rect_center_point
      Geometry.rect_center_point self
    end
  end # module Geometry
end # module GTK
