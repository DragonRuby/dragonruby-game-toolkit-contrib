begin
  if $gtk.args.state.current_turn == :player_1_angle
    $gtk.args.state.player_1_angle = "#{60 + 10.randomize(:ratio).to_i}"
    $you_so_basic_gorillas.input_execute_turn
    $gtk.args.state.player_1_velocity = "#{30 + 20.randomize(:ratio).to_i}"
    $you_so_basic_gorillas.input_execute_turn
  elsif $gtk.args.state.current_turn == :player_2_angle
    $gtk.args.state.player_2_angle = "#{60 + 10.randomize(:ratio).to_i}"
    $you_so_basic_gorillas.input_execute_turn
    $gtk.args.state.player_2_velocity = "#{30 + 20.randomize(:ratio).to_i}"
    $you_so_basic_gorillas.input_execute_turn
  else
    $you_so_basic_gorillas.input_execute_turn
  end
rescue Exception => e
  puts e
end
