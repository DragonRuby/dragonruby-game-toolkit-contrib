# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# entity.rb has been released under MIT (*only this file*).

module GTK
  class Entity
    def self.id!
      @id ||= 0
      @id += 1
      @id
    end

    def self.__reset_id__!
      @id = 0
    end

    def self.strict_entities
      @strict_entities ||= {}
      @strict_entities
    end

    def self.parse_serialization_data value
      if value.is_a?(Hash) && value[:entity_id] && value[:entity_strict]
        o = new_entity_strict value[:entity_name], value
        o.load_entity_data! value
        return o
      elsif value.is_a?(Hash) && value[:entity_id]
        o = OpenEntity.new
        o.load_entity_data! value
        return o
      elsif value.is_a? Array
        return value.map { |entry| Entity.parse_serialization_data entry }
      else
        return value
      end
    end

    def self.new_entity entity_type, init_hash = nil, block = nil
      n = OpenEntity.new(entity_type)
      n.entity_type = entity_type
      n.created_at = Kernel.tick_count
      n.global_created_at = Kernel.global_tick_count

      if init_hash
        init_hash.each do |k, v|
          n.as_hash[k] = v
        end
      end

      block.call(n) if block

      n
    end

    def self.new_entity_strict entity_type, init_hash = nil, block = nil
      if !Entity.strict_entities[entity_type]
        init_hash ||= { }

        n = new_entity entity_type, init_hash, block
        klass = Class.new(StrictEntity)

        klass.class_eval do
          init_hash.each do |k, v|
            attr_accessor k
          end

          n.as_hash.each do |k, v|
            attr_accessor k if !init_hash[k]
          end
        end

        Entity.strict_entities[entity_type] = klass
      end

      klass = Entity.strict_entities[entity_type]
      (klass.new entity_type, init_hash, block)
    end
  end
end
