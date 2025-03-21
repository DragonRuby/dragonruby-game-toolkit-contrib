# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# save_state_load_state.rb has been released under MIT (*only this file*).

module GTK
  class Runtime
    module SaveStateLoadState
      def save_state
        serialize_state "game_state_#{Time.now.to_i}.txt", @args.state
        serialize_state "game_state.txt", @args.state
      end

      def load_state
        @args.state = deserialize_state 'game_state.txt'
      end

      def serialize_state *opts
        maybe_file, maybe_state = opts
        if maybe_file.is_a?(String)
          file = maybe_file
          state = maybe_state
        else
          state = maybe_file
        end

        state.__delete_thrash_count__! if state.respond_to? :__delete_thrash_count__!

        result = if state.is_a? OpenEntity
                   state.as_hash.to_s
                 else
                   state.to_s
                 end

        if file
          write_file file, result
          log_info "State with length of #{result.length} saved to file #{file}."
        end
        if result.length > 20_000
          $serialize_state_serialization_too_large = true
          log_important Help.serialization_too_large
        end
        result
      end

      def deserialize_state *args
        file_or_seralization, _ = args
        # Determine if we are trying to read state from a file or a bare string.
        # If it starts with { or [, it's most likely not a file.
        if file_or_seralization[0] == "{" || file_or_seralization[0] == "["
          definitely_serialization = file_or_seralization
        end

        # If it doesn't start with either of two serialization markers, then it's probably a file.
        # Check the disk for the file.
        if !definitely_serialization
          definitely_serialization = read_file file_or_seralization
        end

        # If the file isn't there, then maybe it's a serialzation without the { or [ delimeter?
        # But only if the string doesn't end in .txt or .dat or .rb
        if !definitely_serialization &&
           !file_or_seralization.strip.end_with?(".txt") &&
           !file_or_seralization.strip.end_with?(".dat") &&
           !file_or_seralization.strip.end_with?(".rb")
          definitely_serialization = file_or_seralization
        end

        return nil unless definitely_serialization

        begin
          load_data = GTK::Codegen.eval_hash("#{definitely_serialization}")
          state = OpenEntity.parse_serialization_data load_data
          Kernel.tick_count = load_data[:tick_count] if load_data[:tick_count]
          state
        rescue Exception => e
          raise e, "Failed to eval: #{definitely_serialization}. #{e}.\nSerialization data may be corrupt."
        end
      end

      def parse_serialization_data value
        if value.is_a?(Hash) && value[:entity_id] && value[:entity_strict]
          o = Entity.new_entity_strict value[:entity_name], value
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
    end # module SaveStateLoadState
  end # class Runtime
end # module GTK

module GTK
  class OpenEntity
    def load_entity_data! serialization_data
      self[:entity_id] = Entity.id!

      serialization_data.each do |k, v|
        self[k] = Entity.parse_serialization_data v
      end

      if serialization_data[:entity_keys_by_ref]
        serialization_data[:entity_keys_by_ref].each do |other_reference, main_reference|
          self[other_reference] = self[main_reference]
        end
      end
    rescue Exception => e
      raise <<-S
* ERROR:
Failed to load entity data from:

#+begin_src
#{serialization_data}
#+end_src

The save data looks to be corrupt.

** INNER EXCEPTION:
#{e}
S
    end

    def to_s
      update_entity_keys_by_ref
      @hash.to_s
    end
  end

  def update_entity_keys_by_ref
    @hash[:entity_keys_by_ref] = {}

    references = {}

    @hash.each do |k, v|
      if !v.is_a?(Symbol) && !v.is_a?(Integer) && !v.is_a?(Float) && !v.is_a?(String)
        references[v.object_id] ||= []
        references[v.object_id] << k
      end
    end

    references.each do |key, values|
      if key
        if values.length > 1
          root_value = values[0]
          values.drop(1).each do |v|
            @hash[:entity_keys_by_ref][v] = root_value if root_value
          end
        end
      end
    end
  end
end

module GTK
  class StrictEntity
    def load_entity_data! serialization_data
      self[:entity_id] = Entity.id!

      serialization_data.each do |k, v|
        self.class.class_eval { attr_accessor k } if !self.respond_to? :k
        self[k] = Entity.parse_serialization_data v
      end

      if serialization_data[:entity_keys_by_ref]
        serialization_data[:entity_keys_by_ref].each do |other_reference, main_reference|
          self[other_reference] = self[main_reference]
        end
      end
    rescue Exception => e
      raise <<-S
* ERROR:
Failed to load entity data from:

#+begin_src
#{serialization_data}
#+end_src

The save data looks to be corrupt.

** INNER EXCEPTION:
#{e}
S
    end

    def to_s
      update_entity_keys_by_ref
      to_hash.to_s
    end

    def update_entity_keys_by_ref
      @entity_keys_by_ref = {}

      references = {}

      instance_variables.each do |k|
        v = instance_variable_get k
        if !v.is_a?(Symbol) && !v.is_a?(Integer) && !v.is_a?(Float) && !v.is_a?(String)
          references[v.object_id] ||= []
          references[v.object_id] << (k.to_s.gsub "@", "").to_sym
        end
      end

      references.each do |key, values|
        if values.length > 1
          root_value = values[0]
          values.drop(1).each do |v|
            @entity_keys_by_ref[v] = root_value
          end
        end
      end
    end
  end
end
