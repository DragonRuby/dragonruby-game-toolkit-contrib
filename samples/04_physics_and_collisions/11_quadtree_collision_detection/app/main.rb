# A quadtree can quickly determine if a rectangle intersects any in a
# collection of static rectangles
# the creation of a quadtree is slow but the intersection detection is fast
# read more here: https://en.wikipedia.org/wiki/Quadtree

class QuadTree
  class << self
    def intersect_rect? rect_one, rect_two
      GTK::Geometry.intersect_rect? rect_one, rect_two
    end

    def inside_rect? outer, inner
      return false if !outer
      return false if !inner
      (inner.x)           >= (outer.x)           &&
      (inner.x + inner.w) <= (outer.x + outer.w) &&
      (inner.y)           >= (outer.y)           &&
      (inner.y + inner.h) <= (outer.y + outer.h)
    end

    def __bounding_box__ rects
      return { x: 0, y: 0, w: 0, h: 0 } if !rects || rects.length == 0
      min_x = rects.first.x
      min_y = rects.first.y
      max_x = rects.first.x + rects.first.w
      max_y = rects.first.y + rects.first.h
      rects.each do |r|
        min_x = r.x if r.x < min_x
        min_y = r.y if r.y < min_y
        max_x = r.x + r.w if (r.x + r.w) > max_x
        max_y = r.y + r.w if (r.y + r.w) > max_y
      end

      { x: min_x, y: min_y, w: max_x - min_x, h: max_y - min_y }
    end

    def __insert_rect__ node, rect
      return if !inside_rect? node.bounding_box, rect

      node.top_left ||= {
        bounding_box: { x: node.bounding_box.x,
                        y: node.bounding_box.y + node.bounding_box.h / 2,
                        w: node.bounding_box.w / 2,
                        h: node.bounding_box.h / 2 },
        rects: []
      }

      node.top_right ||= {
        bounding_box: { x: node.bounding_box.x + node.bounding_box.w / 2,
                        y: node.bounding_box.y + node.bounding_box.h / 2,
                        w: node.bounding_box.w / 2,
                        h: node.bounding_box.h / 2 },
        rects: []
      }

      node.bottom_left ||= {
        bounding_box: { x: node.bounding_box.x,
                        y: node.bounding_box.y,
                        w: node.bounding_box.w / 2,
                        h: node.bounding_box.h / 2 },
        rects: []
      }

      node.bottom_right ||= {
        bounding_box: { x: node.bounding_box.x + node.bounding_box.w / 2,
                        y: node.bounding_box.y,
                        w: node.bounding_box.w / 2,
                        h: node.bounding_box.h / 2 },
        rects: []
      }

      if inside_rect? node.top_left.bounding_box, rect
        __insert_rect__ node.top_left, rect
      elsif inside_rect? node.top_right.bounding_box, rect
        __insert_rect__ node.top_right, rect
      elsif inside_rect? node.bottom_left.bounding_box, rect
        __insert_rect__ node.bottom_left, rect
      elsif inside_rect? node.bottom_right.bounding_box, rect
        __insert_rect__ node.bottom_right, rect
      else
        node.rects << rect
      end
    end

    def create rects
      tree = {
        bounding_box: (__bounding_box__ rects),
        rects: []
      }

      rects.each { |rect| __insert_rect__ tree, rect }

      tree
    end

    def find_intersect node, rect
      return nil if !node
      return nil if !intersect_rect? node.bounding_box, rect

      result = node.rects.find { |r| intersect_rect? r, rect }

      if !result && node.top_left && intersect_rect?(node.top_left.bounding_box, rect)
        result = find_intersect node.top_left, rect
      end

      if !result && node.top_right && intersect_rect?(node.top_right.bounding_box, rect)
        result = find_intersect node.top_right, rect
      end

      if !result && node.bottom_left && intersect_rect?(node.bottom_left.bounding_box, rect)
        result = find_intersect node.bottom_left, rect
      end

      if !result && node.bottom_right && intersect_rect?(node.bottom_right.bounding_box, rect)
        result = find_intersect node.bottom_right, rect
      end

      result
    end
  end
end

def tick args
  render_instructions args

  args.state.rects ||= []
  args.state.quad_tree ||= nil

  # add a rect at each mouse click and recalculate quadtree
  if args.inputs.mouse.click
    args.state.rects << { x: args.inputs.mouse.x, y: args.inputs.mouse.y, w: 10, h: 10 }
    args.state.quad_tree = QuadTree.create args.state.rects
  end

  # render quadtree
  render_quadtree args, args.state.quad_tree
  args.outputs.solids << args.state.rects.map { |r| r.merge(b: 255) }

  # have a rectangle that can be moved around using arrow keys
  args.state.player_rect ||= { x: 100, y: 100, w: 100, h: 100, r: 180, g: 30, b: 130 }
  args.state.player_rect[:x] += args.inputs.left_right * 4
  args.state.player_rect[:y] += args.inputs.up_down * 4
  args.outputs.borders << args.state.player_rect

  # check for collision, and if a collision occurs, make that rectangle from the quadtree a different color
  collision = QuadTree.find_intersect args.state.quad_tree, args.state.player_rect
  args.outputs.solids << collision.merge(r: 255) if collision
end

def render_quadtree args, quadtree
  return unless quadtree
  args.outputs.borders << quadtree.bounding_box
  render_quadtree args, quadtree.top_left
  render_quadtree args, quadtree.top_right
  render_quadtree args, quadtree.bottom_left
  render_quadtree args, quadtree.bottom_right
end

def render_instructions args
  args.outputs.labels << { x: 10, y: 30.from_top, text: "Click around to add points" }
  args.outputs.labels << { x: 10, y: 50.from_top, text: "Use arrow keys to move player" }
end
