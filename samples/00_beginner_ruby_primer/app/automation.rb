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
# following code a bit overwhelming. Come back to this file when you have
# a better grasp of Ruby and Game Toolkit.
#
# What follows is an automations script # that can be run via terminal:
# ./samples/00_beginner_ruby_primer $ ../../dragonruby . --eval app/automation.rb
# ==========================================================================

$gtk.reset
$gtk.scheduled_callbacks.clear
$gtk.schedule_callback 10 do
  $gtk.console.set_command 'puts "Hello DragonRuby!"'
end

$gtk.schedule_callback 20 do
  $gtk.console.eval_the_set_command
end

$gtk.schedule_callback 30 do
  $gtk.console.set_command 'outputs.solids << [910, 200, 100, 100, 255, 0, 0]'
end

$gtk.schedule_callback 40 do
  $gtk.console.eval_the_set_command
end

$gtk.schedule_callback 50 do
  $gtk.console.set_command 'outputs.solids << [1010, 200, 100, 100, 0, 0, 255]'
end

$gtk.schedule_callback 60 do
  $gtk.console.eval_the_set_command
end

$gtk.schedule_callback 70 do
  $gtk.console.set_command 'outputs.sprites << [1110, 200, 100, 100, "sprites/dragon_fly_0.png"]'
end

$gtk.schedule_callback 80 do
  $gtk.console.eval_the_set_command
end

$gtk.schedule_callback 90 do
  $gtk.console.set_command "outputs.labels << [1210, 200, state.tick_count, 0, 255, 0]"
end

$gtk.schedule_callback 100 do
  $gtk.console.eval_the_set_command
end

$gtk.schedule_callback 110 do
  $gtk.console.set_command "state.sprite_frame = state.tick_count.idiv(4).mod(6)"
end

$gtk.schedule_callback 120 do
  $gtk.console.eval_the_set_command
end

$gtk.schedule_callback 130 do
  $gtk.console.set_command "outputs.labels << [1210, 170, state.sprite_frame, 0, 255, 0]"
end

$gtk.schedule_callback 140 do
  $gtk.console.eval_the_set_command
end

$gtk.schedule_callback 150 do
  $gtk.console.set_command "state.sprite_path =  \"sprites/dragon_fly_\#{state.sprite_frame}.png\""
end

$gtk.schedule_callback 160 do
  $gtk.console.eval_the_set_command
end

$gtk.schedule_callback 170 do
  $gtk.console.set_command "outputs.labels    << [910, 330, \"path: \#{state.sprite_path}\", 0, 255, 0]"
end

$gtk.schedule_callback 180 do
  $gtk.console.eval_the_set_command
end

$gtk.schedule_callback 190 do
  $gtk.console.set_command "outputs.sprites   << [910, 330, 370, 370, state.sprite_path]"
end

$gtk.schedule_callback 200 do
  $gtk.console.eval_the_set_command
end

$gtk.schedule_callback 300 do
  $gtk.console.set_command ":wq"
end

$gtk.schedule_callback 400 do
  $gtk.console.eval_the_set_command
end
