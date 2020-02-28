# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# geometry.rb has been released under MIT (*only this file*).

module GTK
  module Geometry
    def inside_rect? outer
      Geometry.inside_rect? self, outer
    end

    def intersect_rect? other, tolerance = 0.1
      Geometry.intersect_rect? self, other, tolerance
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

    def scale_rect percentage, *anchors
      Geometry.scale_rect self, percentage, *anchors
    end

    def angle_to other_point
      Geometry.angle_to self, other_point
    end

    def angle_from other_point
      Geometry.angle_from self, other_point
    end

    def point_inside_circle? circle_center_point, radius
      Geometry.point_inside_circle? self, circle_center_point, radius
    end

    def anchor_rect anchor_x, anchor_y
      current_w = self.w
      current_h = self.h
      delta_x = -1 * (anchor_x * current_w)
      delta_y = -1 * (anchor_y * current_h)
      self.rect_shift(delta_x, delta_y)
    end

    def angle_given_point other_point
      raise ":angle_given_point has been deprecated use :angle_from instead."
    end

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

    def self.line_y_intercept line
      line.y - line_slope(line) * line.x
    end

    def self.angle_between_lines line_one, line_two, replace_infinity: nil
      m_line_one = line_slope line_one, replace_infinity: replace_infinity
      m_line_two = line_slope line_two, replace_infinity: replace_infinity
      Math.atan((m_line_one - m_line_two) / (1 + m_line_two * m_line_one)).to_degrees
    end

    def self.line_slope line, replace_infinity: nil
      (line.y2 - line.y).fdiv(line.x2 - line.x)
                        .replace_infinity(replace_infinity)
    end

    def self.ray_test point, line
      slope = (line.y2 - line.y).fdiv(line.x2 - line.x)

      if line.x > line.x2
        point_two, point_one = [point_one, point_two]
      end

      r = ((line.x2 - line.x) * (point.y - line.y) -
           (point.x -  line.x) * (line.y2 - line.y))

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

    def self.line_rect line
      if line.x > line.x2
        x  = line.x2
        y  = line.y2
        x2 = line.x
        y2 = line.y
      else
        x  = line.x
        y  = line.y
        x2 = line.x2
        y2 = line.y2
      end

      w = x2 - x
      h = y2 - y

      { x: x, y: y, w: w, h: h }
    end

    def self.line_intersect line_one, line_two
      m1 = line_slope(line_one)
      m2 = line_slope(line_two)
      b1 = line_y_intercept(line_one)
      b2 = line_y_intercept(line_two)
      x = (b1 - b2) / (m2 - m1)
      y = (-b2.fdiv(m2) + b1.fdiv(m1)).fdiv(1.fdiv(m1) - 1.fdiv(m2))
      [x, y]
    end

    def self.intersect_rect? rect_one, rect_two, tolerance = 0.1
      return false if rect_one.right - tolerance < rect_two.left + tolerance
      return false if rect_one.left + tolerance > rect_two.right - tolerance
      return false if rect_one.top - tolerance < rect_two.bottom + tolerance
      return false if rect_one.bottom + tolerance > rect_two.top - tolerance
      return true
    rescue Exception => e
      raise e, ":intersect_rect? failed for rect_one: #{rect_one} rect_two: #{rect_two}."
    end

    def self.to_square size, x, y, anchor_x = 0.5, anchor_y = nil
      anchor_y ||= anchor_x
      x = x.shift_left(size * anchor_x)
      y = y.shift_down(size * anchor_y)
      [x, y, size, size]
    rescue Exception => e
      raise e, ":to_square failed for size: #{size} x: #{x} y: #{y} anchor_x: #{anchor_x} anchor_y: #{anchor_y}."
    end

    def self.distance point_one, point_two
      Math.sqrt((point_two.x - point_one.x)**2 + (point_two.y - point_one.y)**2)
    rescue Exception => e
      raise e, ":distance failed for point_one: #{point_one} point_two #{point_two}."
    end

    def self.angle_from start_point, end_point
      d_y = end_point.y - start_point.y
      d_x = end_point.x - start_point.x
      Math::PI.+(Math.atan2(d_y, d_x)).to_degrees
    rescue Exception => e
      raise e, ":angle_from failed for start_point: #{start_point} end_point: #{end_point}."
    end

    def self.angle_to start_point, end_point
      angle_from end_point, start_point
    rescue Exception => e
      raise e, ":angle_to failed for start_point: #{start_point} end_point: #{end_point}."
    end

    def self.point_inside_circle? point, circle_center_point, radius
      (point.x - circle_center_point.x) ** 2 + (point.y - circle_center_point.y) ** 2 < radius ** 2
    rescue Exception => e
      raise e, ":point_inside_circle? failed for point: #{point} circle_center_point: #{circle_center_point} radius: #{radius}"
    end

    def self.inside_rect? inner_rect, outer_rect
      inner_rect.x >= outer_rect.x &&
      inner_rect.right <= outer_rect.right &&
      inner_rect.y >= outer_rect.y &&
      inner_rect.top <= outer_rect.top
    rescue Exception => e
      raise e, ":inside_rect? failed for inner_rect: #{inner_rect} outer_rect: #{outer_rect}."
    end

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
      raise e, ":scale_rect_extended failed for rect: #{rect} percentage_x: #{percentage_x} percentage_y: #{percentage_y} anchors_x: #{anchor_x} anchor_y: #{anchor_y}."
    end

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
      raise e, ":scale_rect failed for rect: #{rect} percentage: #{percentage} anchors [#{anchor_x} (x), #{anchor_y} (y)]."
    end
  end # module Geometry
end # module GTK
