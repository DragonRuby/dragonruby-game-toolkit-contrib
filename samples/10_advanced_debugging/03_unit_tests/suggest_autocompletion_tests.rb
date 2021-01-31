def default_suggest_autocompletion args
  {
    index: 4,
    text: "args.",
    __meta__: {
      other_options: [
        {
          index: Fixnum,
          file: "app/main.rb"
        }
      ]
    }
  }
end

def assert_completion source, *expected
  results = suggest_autocompletion text:  (source.strip.gsub  ":cursor", ""),
                                   index: (source.strip.index ":cursor")

  puts results
end

def test_args_completion args, assert
  $gtk.write_file_root "autocomplete.txt", ($gtk.suggest_autocompletion text: <<-S, index: 128).join("\n")
require 'app/game.rb'

def tick args
  args.gtk.suppress_mailbox = false
  $game ||= Game.new
  $game.args = args
  $game.args.
  $game.tick
end
S

  puts "contents:"
  puts ($gtk.read_file "autocomplete.txt")
end
