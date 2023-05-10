# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# attr_gtk.rb has been released under MIT (*only this file*).

module AttrGTK
  def args= value
    @__args__ = value
  end

  def args
    @__args__
  end

  def keyboard
    @__keyboard__ ||= @__args__.inputs.keyboard
  end

  def grid
    @__grid__ ||= @__args__.grid
  end

  def state
    @__state__ ||= @__args__.state
  end

  def temp_state
    @__temp_state__ ||= @__args__.temp_state
  end

  def inputs
    @__inputs__ ||= @__args__.inputs
  end

  def outputs
    @__outputs__ ||= @__args__.outputs
  end

  def gtk
    @__gtk__ ||= @__args__.gtk
  end

  def passes
    @__passes__ ||= @__args__.passes
  end

  def pixel_arrays
    @__pixel_arrays__ ||= @__args__.pixel_arrays
  end

  def geometry
    @__geometry__ ||= @__args__.geometry
  end

  def layout
    @__layout__ ||= @__args__.layout
  end

  def easing
    @__easing__ ||= @__args__.easing
  end

  def audio
    @__audio__ ||= @__args__.audio
  end

  def events
    @__events__ ||= @__args__.events
  end

  def new_entity entity_type, init_hash = nil, &block
    self.state.new_entity entity_type, init_hash, &block
  end

  def new_entity_strict entity_type, init_hash = nil, &block
    self.state.new_entity_strict entity_type, init_hash, &block
  end
end

class Object
  def self.attr_gtk
    include AttrGTK
  end

  def attr_gtk
    return if self.is_a? AttrGTK
    self.class.include AttrGTK
  end
end
