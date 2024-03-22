# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# geometry_docs.rb has been released under MIT (*only this file*).

module GeometryDocs
  def docs_method_sort_order
    [
      :docs_class,
      :docs_intersect_rect?,
      :docs_inside_rect?,
      :docs_scale_rect,
      :docs_scale_rect_extended,
      :docs_anchor_rect,
      :docs_angle,
      :docs_angle_from,
      :docs_angle_to,
      :docs_angle_turn_direction,
      :docs_distance,
      :docs_point_inside_circle?,
      :docs_center_inside_rect,
      :docs_ray_test,
      :docs_line_rise_run,
      :docs_line_intersect,
      :docs_ray_intersect,
      #:docs_cubic_bezier
      :docs_rotate_point,
      :docs_find_intersect_rect,
      :docs_find_all_intersect_rect,
      :docs_find_intersect_rect_quad_tree,
      :docs_find_all_intersect_rect_quad_tree,
      :docs_quad_tree_create,
      # added because of bouncing ball sample app
      :docs_line_angle,
      :docs_vec2_dot_product,
      :docs_vec2_normalize,
      :docs_rect_normalize,
      :docs_line_vec2,
      :docs_vec2_magnitude,
      :docs_distance_squared,
      :docs_vec2_normal,
      :docs_circle_intersect_line?,
      :docs_line_normal,
      :docs_point_on_line?,
      :docs_find_collisions,
      :docs_rect_navigate
    ]
  end

  def docs_class
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 1,
                                      heading_include: "Geometry",
                                      max_depth: 0
  end

  def docs_find_intersect_rect
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_find_all_intersect_rect
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_create_quad_tree
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_find_intersect_rect_quad_tree
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_find_all_intersect_rect_quad_tree
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_anchor_rect
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_angle
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_angle_from
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_angle_turn_direction
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_angle_to
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_distance
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_point_inside_circle?
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_center_inside_rect
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_ray_test
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_line_intersect
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_ray_intersect
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_line_rise_run
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_rotate_point
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_intersect_rect?
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_inside_rect?
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_scale_rect
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_scale_rect_extended
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_line_angle
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_vec2_dot_product
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_rect_normalize
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_vec2_normalize
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_line_vec2
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_vec2_magnitude
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_distance_squared
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_vec2_normal
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_circle_intersect_line?
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_line_normal
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_point_on_line?
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_find_collisions
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_rect_navigate
    DocsOrganizer.get_docsify_content path: "docs/api/geometry.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  # todo
  # docs_angle_between_lines
  # docs_line_rect
  # docs_line_slope
  # docs_line_y_intercept
  # docs_rect_center_point
  # docs_rect_to_line
  # docs_shift_line
  # docs_shift_rect
end

module Geometry
  extend Docs
  extend GeometryDocs
end
