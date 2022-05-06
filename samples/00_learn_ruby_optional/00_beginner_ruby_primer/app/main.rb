# ==========================================================================
#  _    _ ________     __  _      _____  _____ _______ ______ _   _ _ _ _ _
# | |  | |  ____\ \   / / | |    |_   _|/ ____|__   __|  ____| \ | | | | | |
# | |__| | |__   \ \_/ /  | |      | | | (___    | |  | |__  |  \| | | | | |
# |  __  |  __|   \   /   | |      | |  \___ \   | |  |  __| | . ` | | | | |
# | |  | | |____   | |    | |____ _| |_ ____) |  | |  | |____| |\  |_|_|_|_|
# |_|  |_|______|  |_|    |______|_____|_____/   |_|  |______|_| \_(_|_|_|_)
#
#
#                                   |
#                                   |
#                                   |
#                                   |
#                                   |
#                                   |
#                                   |
#                                   |
#                                   |
#                                   |
#                                \  |  /
#                                 \ | /
#                                   +
#
# If you are new to the programming language Ruby, then you may find the
# following code a bit overwhelming. This sample is only designed to be
# run interactively (as opposed to being manipulated via source code).
#
# Start up this sample and follow along by visiting:
# https://s3.amazonaws.com/s3.dragonruby.org/dragonruby-gtk-primer.mp4
#
# It is STRONGLY recommended that you work through all the samples before
# looking at the code in this file.
# ==========================================================================

class TutorialOutputs
  attr_accessor :solids, :sprites, :labels, :lines, :borders

  def initialize
    @solids  = []
    @sprites = []
    @labels  = []
    @lines   = []
    @borders = []
  end

  def tick
    @solids  ||= []
    @sprites ||= []
    @labels  ||= []
    @lines   ||= []
    @borders ||= []
    @solids.each  { |p| $gtk.args.outputs.reserved << p.solid  }
    @sprites.each { |p| $gtk.args.outputs.reserved << p.sprite }
    @labels.each  { |p| $gtk.args.outputs.reserved << p.label  }
    @lines.each   { |p| $gtk.args.outputs.reserved << p.line   }
    @borders.each { |p| $gtk.args.outputs.reserved << p.border }
  end

  def clear
    @solids.clear
    @sprites.clear
    @labels.clear
    @borders.clear
  end
end

def defaults
  state.reset_button ||=
    state.new_entity(
      :button,
      label:  [1190, 68, "RESTART", -2, 0, 0, 0, 0].label,
      background: [1160, 38, 120, 50, 255, 255, 255].solid
    )
  $gtk.log_level = :off
end

def tick_reset_button
  return unless state.hello_dragonruby_confirmed
  $gtk.args.outputs.reserved << state.reset_button.background
  $gtk.args.outputs.reserved << state.reset_button.label
  if inputs.mouse.click && inputs.mouse.click.point.inside_rect?(state.reset_button.background)
    restart_tutorial
  end
end

def seperator
  @seperator = "=" * 80
end

def tick_intro
  queue_message "Welcome to the DragonRuby GTK primer! Try typing the
code below and press ENTER:

    puts \"Hello DragonRuby!\"
"
end

def tick_hello_dragonruby
  return unless console_has? "Hello DragonRuby!", "puts "

  $gtk.args.state.hello_dragonruby_confirmed = true

  queue_message "Well HELLO to you too!

If you ever want to RESTART the tutorial, just click the \"RESTART\"
button in the bottom right-hand corner.

Let's continue shall we? Type the code below and press ENTER:

    outputs.solids << [910, 200, 100, 100, 255, 0, 0]
"

end

def tick_explain_solid
  return unless $tutorial_outputs.solids.any? {|s| s == [910, 200, 100, 100, 255, 0, 0]}

  queue_message "Sweet!

The code: outputs.solids << [910, 200, 100, 100, 255, 0, 0]
Does the following:
1. GET the place where SOLIDS go: outputs.solids
2. Request that a new SOLID be ADDED: <<
3. The DEFINITION of a SOLID is the ARRAY:
   [910, 200, 100, 100, 255, 0, 0]

      GET       ADD     X      Y    WIDTH  HEIGHT RED  GREEN  BLUE
       |         |      |      |      |      |     |     |     |
       |         |      |      |      |      |     |     |     |
outputs.solids  <<    [910,   200,   100,   100,  255,   0,    0]
                      |_________________________________________|
                                           |
                                           |
                                         ARRAY

Now let's create a blue SOLID. Type:

    outputs.solids << [1010, 200, 100, 100, 0, 0, 255]
"

  state.explain_solid_confirmed = true
end

def tick_explain_solid_blue
  return unless state.explain_solid_confirmed
  return unless $tutorial_outputs.solids.any? {|s| s == [1010, 200, 100, 100, 0, 0, 255]}
  state.explain_solid_blue_confirmed = true

  queue_message "And there is our blue SOLID!

The ARRAY is the MOST important thing in DragonRuby GTK.

Let's create a SPRITE using an ARRAY:

  outputs.sprites << [1110, 200, 100, 100, 'sprites/dragon_fly_0.png']
"
end

def tick_explain_tick_count
  return unless $tutorial_outputs.sprites.any? {|s| s == [1110, 200, 100, 100, 'sprites/dragon_fly_0.png']}
  return if $tutorial_outputs.labels.any? {|l| l == [1210, 200, state.tick_count, 255, 255, 255]}
  state.explain_tick_count_confirmed = true

  queue_message "Look at the cute little dragon!

We can create a LABEL with ARRAYS too. Let's create a LABEL showing
THE PASSAGE OF TIME, which is called TICK_COUNT.

  outputs.labels << [1210, 200, state.tick_count, 0, 255, 0]
"
end

def tick_explain_mod
  return unless $tutorial_outputs.labels.any? {|l| l == [1210, 200, state.tick_count, 0, 255, 0]}
  state.explain_mod_confirmed = true
  queue_message "
The code: outputs.labels << [1210, 200, state.tick_count, 0, 255, 0]
Does the following:
1. GET the place where labels go: outputs.labels
2. Request that a new label be ADDED: <<
3. The DEFINITION of a LABEL is the ARRAY:
   [1210, 200, state.tick_count, 0, 255, 0]

      GET       ADD     X      Y          TEXT         RED  GREEN  BLUE
       |         |      |      |            |           |     |     |
       |         |      |      |            |           |     |     |
outputs.labels  <<    [1210,  200,   state.tick_count,  0,   255,   0]
                      |______________________________________________|
                                              |
                                              |
                                            ARRAY

Now let's do some MATH, save the result to STATE, and create a LABEL:

    state.sprite_frame = state.tick_count.idiv(4).mod(6)
    outputs.labels << [1210, 170, state.sprite_frame, 0, 255, 0]

Type the lines above (pressing ENTER after each line).
"
end

def tick_explain_string_interpolation
  return unless state.explain_mod_confirmed
  return unless state.sprite_frame == state.tick_count.idiv(4).mod(6)
  return unless $tutorial_outputs.labels.any? {|l| l == [1210, 170, state.sprite_frame, 0, 255, 0]}

  queue_message "Here is what the mathematical computation you just typed does:

1. Create an item of STATE named SPRITE_FRAME: state.sprite_frame =
2. Set this SPRITE_FRAME to the PASSAGE OF TIME (tick_count),
   DIVIDED EVENLY (idiv) into 4,
   and then compute the REMAINDER (mod) of 6.

   STATE   SPRITE_FRAME    PASSAGE OF      HOW LONG   HOW MANY
     |          |             TIME         TO SHOW    IMAGES
     |          |              |           AN IMAGE   TO FLIP THROUGH
     |          |              |               |      |
state.sprite_frame =     state.tick_count.idiv(4).mod(6)
                                           |       |
                                           |       +- REMAINDER OF DIVIDE
                                    DIVIDE EVENLY
                                    (NO DECIMALS)

With the information above, we can animate a SPRITE
using STRING INTERPOLATION: \#{}
which creates a unique SPRITE_PATH:

  state.sprite_path =  \"sprites/dragon_fly_\#{state.sprite_frame}.png\"
  outputs.labels    << [910, 330, \"path: \#{state.sprite_path}\", 0, 255, 0]
  outputs.sprites   << [910, 330, 370, 370, state.sprite_path]

Type the lines above (pressing ENTER after each line).
"
end

def tick_reprint_on_error
  return unless console.last_command_errored
  puts $gtk.state.messages.last
  puts "\nWhoops! Try again."
  console.last_command_errored = false
end

def tick_evals
  state.evals ||= []
  if console.last_command && (console.last_command.start_with?("outputs.") || console.last_command.start_with?("state."))
    state.evals << console.last_command
    console.last_command = nil
  end

  state.evals.each do |l|
    Kernel.eval l
  end
rescue Exception => e
  state.evals = state.evals[0..-2]
end

$tutorial_outputs ||= TutorialOutputs.new

def tick args
  $gtk.log_level = :off
  defaults
  console.show
  $tutorial_outputs.clear
  $tutorial_outputs.solids  << [900, 37, 480, 700,   0,   0,   0, 255]
  $tutorial_outputs.borders << [900, 37, 380, 683, 255, 255, 255]
  tick_evals
  $tutorial_outputs.tick
  tick_intro
  tick_hello_dragonruby
  tick_reset_button
  tick_explain_solid
  tick_explain_solid_blue
  tick_reprint_on_error
  tick_explain_tick_count
  tick_explain_mod
  tick_explain_string_interpolation
end

def console
  $gtk.console
end

def queue_message message
  $gtk.args.state.messages ||= []
  return if $gtk.args.state.messages.include? message
  $gtk.args.state.messages << message
  last_three = [$gtk.console.log[-3], $gtk.console.log[-2], $gtk.console.log[-1]].reject_nil
  $gtk.console.log.clear
  puts seperator
  $gtk.console.log += last_three
  puts seperator
  puts message
  puts seperator
end

def console_has? message, not_message = nil
  console.log
         .map(&:upcase)
         .reject { |s| not_message && s.include?(not_message.upcase) }
         .any?   { |s| s.include?("#{message.upcase}") }
end

def restart_tutorial
  $tutorial_outputs.clear
  $gtk.console.log.clear
  $gtk.reset
  puts "Starting the tutorial over!"
end

def state
  $gtk.args.state
end

def inputs
  $gtk.args.inputs
end

def outputs
  $tutorial_outputs
end
