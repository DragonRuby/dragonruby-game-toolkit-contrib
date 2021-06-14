# Copyright 2019 DragonRuby LLC
# MIT License
# autocomplete.rb has been released under MIT (*only this file*).

module GTK
  class Runtime
    module Autocomplete
      def autocomplete_parse opts
        if opts[:file] && !opts[:text]
          opts[:text] = read_file opts[:file]
        end

        text  = opts[:text]
        index = opts[:index]
        sum   = 0
        lines = text.each_line.to_a.map do |l|
          sum += l.length
          { line: l, length: l.length, sum: sum }
        end
        cursor_line   = lines.find { |l| l[:sum] >= index }
        previous_line = lines.find { |l| l[:sum] < index }
        previous_line ||= { sum: 0 }
        if cursor_line
          sub_index       = index - previous_line[:sum]
          word            = (cursor_line[:line][0..sub_index - 1]).strip
          token           = (word.split " ")[-1]
          dots            = (token.split ".")
          dot             = dots[-1]
        end

        {
          text:          opts[:text],
          file:          opts[:file],
          index:         opts[:index],
          cursor_line:   cursor_line,
          previous_line: previous_line,
          word:          word,
          token:         token,
          dots:          dots,
          dot:           dot
        }
      end

      def autocomplete_filter_methods keys, *ignores
        ignores ||= []
        ignores   = [ignores].flatten
        keys   = keys.map { |k| k.to_s }
        others = ["def", "end"] +
                 [ :entity_keys_by_ref,
                   :entity_name,
                   :as_hash,
                   :clear!,
                   :created_at_elapsed,
                   :entity_id,
                   "entity_id=",
                   "tick_count=",
                   :global_created_at_elapsed,
                   :load_entity_data!,
                   :meta,
                   :meta!,
                   :new?,
                   :old?,
<<<<<<< HEAD
                   :__original_eq_eq__, :set!,
=======
                   :original_eq_eq, :set!,
>>>>>>> 7b9fc2b8c7df352e379c6d14dfd205e6800a2a0e
                   :update_entity_keys_by_ref,
                   :with_meta] +
                 ignores + keys.find_all { |k| k.to_s.to_i.to_s == k.to_s }

        final = (keys - (others.map { |m| m.to_s })).uniq
        final
      end

      def suggest_autocompletion opts
        parse_result = autocomplete_parse opts
        return [] unless parse_result[:cursor_line]
        text  = parse_result[:text]
        word  = parse_result[:word]
        token = parse_result[:token]
        dots  = parse_result[:dots]
        dot   = parse_result[:dot]

        return [] if word.strip.start_with? "#"

        if word[-1] == "." && token
          lookup = {
<<<<<<< HEAD
            'args'     => lambda { $gtk.args.autocomplete_methods },
            'inputs'   => lambda { $gtk.args.inputs.autocomplete_methods },
            'geometry' => lambda { $gtk.args.geometry.autocomplete_methods },
            'outputs'  => lambda { $gtk.args.outputs.autocomplete_methods },
            'layout'   => lambda { $gtk.args.layouts.autocomplete_methods },
            'keyboard' => lambda { $gtk.args.keyboard.autocomplete_methods },
            'key_down' => lambda { $gtk.args.keyboard.key_down.autocomplete_methods },
            'key_up'   => lambda { $gtk.args.keyboard.key_up.autocomplete_methods },
            'state'    => lambda { $gtk.args.state.autocomplete_methods },
            'fn'       => lambda { $gtk.args.fn.autocomplete_methods },
            '$gtk'     => lambda { $gtk.autocomplete_methods },
            'gtk'      => lambda { $gtk.autocomplete_methods },
            'mouse'    => lambda { $gtk.args.inputs.mouse.autocomplete_methods },
            'click'    => lambda { [:x, :y, :point] }
=======
            'args'     => lambda { $gtk.args },
            'inputs'   => lambda { $gtk.args.inputs },
            'outputs'  => lambda { $gtk.args.outputs },
            'layout'  => lambda { $gtk.args.outputs },
            'keyboard' => lambda { $gtk.args.keyboard },
            'key_down' => lambda { $gtk.args.keyboard.key_down },
            'key_up'   => lambda { $gtk.args.keyboard.key_up },
            'state'    => lambda { $gtk.args.state },
            '$gtk'     => lambda { $gtk }
>>>>>>> 7b9fc2b8c7df352e379c6d14dfd205e6800a2a0e
          }

          lookup_result = lookup[dot]

<<<<<<< HEAD
          return autocomplete_filter_methods lookup_result.call if lookup_result
=======
          return autocomplete_filter_methods lookup_result.call.autocomplete_methods if lookup_result
>>>>>>> 7b9fc2b8c7df352e379c6d14dfd205e6800a2a0e

          start_collecting = false
          dots_after_state = dots.find_all do |s|
            if s == "state"
              start_collecting = true
              false
            else
              start_collecting
            end
          end

          target = $gtk.args.state
          dots_after_state.each do |k|
            target = target.as_hash[k.to_sym] if target.respond_to? :as_hash
          end

          return autocomplete_filter_methods target.as_hash.keys
        end


        text.gsub!("[", " ")
        text.gsub!("]", " ")
        text.gsub!("(", " ")
        text.gsub!(")", " ")
        text.gsub!(":", "")
        text.gsub!(".", " ")
        text.gsub!("=", " ")
        return (autocomplete_filter_methods (text.split " "),
                                            :gtk, :false, :true, :args, :suppress_mailbox, :end)
      end
    end # end Autocomplete
  end # end Runtime
end # end GTK
