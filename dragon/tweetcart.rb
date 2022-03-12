# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# tweetcart.rb has been released under MIT (*only this file*).

def $top_level.TICK &block
  $top_level.define_method(:tick) do |args|
    args.outputs[:scene].w = 160
    args.outputs[:scene].h = 90
    args.outputs[:scene].background_color = [0, 0, 0, 0]
    args.state.tweet_scene ||= { x: 0, y: 0, w: 1280, h: 720, path: :scene }
    block.call args
    args.outputs.sprites << args.state.tweet_scene
  end

  def $top_level.no_clear! render_target_name
    $args.outputs[:render_target_name].clear_before_render = false
  end

  def $top_level.bg! *rgb
    r,g,b = rgb
    r ||= 255
    g ||= r
    b ||= g
    $args.outputs.background_color = [r, g, b]
  end

  def $top_level.slds
    $args.outputs[:scene].sprites
  end

  def $top_level.slds! *os
    if (os.first.is_a? Numeric)
      sld!(*os)
    else
      os.each { |o| sld!(*o) }
    end
  end

  def $top_level.sld! *params
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

  def $top_level.sin_r radians
    Math.sin radians
  end

  def $top_level.cos_r radians
    Math.cos radians
  end

  def $top_level.sin degrees
    Math.sin degrees.to_radians
  end

  def $top_level.cos degrees
    Math.cos degrees.to_radians
  end

  def $top_level.sin_d degrees
    Math.sin degrees.to_radians
  end

  def $top_level.cos_d degrees
    Math.cos degrees.to_radians
  end

  def $top_level.tc
    $args.state.tick_count
  end

  def $top_level.scene! w = 1280, h = 720
    $args.outputs[:scene].w = w
    $args.outputs[:scene].h = h
    $args.state.tweet_scene.w = w
    $args.state.tweet_scene.h = h
    $args.state.tweet_scene.x = ($args.grid.w - w) / 2
    $args.state.tweet_scene.y = ($args.grid.h - h) / 2
  end
end

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
=end
