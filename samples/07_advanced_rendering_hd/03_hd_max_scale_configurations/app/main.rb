module Main
  def tick args
    args.state.current_test_index ||= 1
    args.state.is_running ||= :no

    if args.inputs.keyboard.key_down.enter
      m = "test_#{args.state.current_test_index}"
      args.state.is_running = :yes
      DR.notify "Running test_#{args.state.current_test_index}."
      puts "* INFO - invoke test #{m}"
      send m, args
      args.state.current_test_index += 1
      if args.state.current_test_index > 13
        DR.notify "All tests complete."
        args.state.current_test_index = 1
      end
    end

    args.outputs.watch "Instructions: Press ENTER to change window configuration."
    args.outputs.watch "Current test running?: #{args.state.is_running}"
    args.outputs.watch "Next test: test_#{args.state.current_test_index}"
    props.each { |prop| args.outputs.watch prop }
  end

  def test_1 args
    DR.set_window_fullscreen false
    DR.set_window_size 1280, 720
    DR.set_hd_max_scale 0
    DR.set_hd_letterbox true
    print_props args, "== TEST 1 =="
  end

  def test_2 args
    DR.set_window_fullscreen false
    DR.maximize_window
    DR.set_hd_max_scale 0
    DR.set_hd_letterbox true
    print_props args, "== TEST 2 =="
  end

  def test_3 args
    DR.set_window_fullscreen false
    DR.set_window_size 640, 1136
    DR.set_hd_max_scale 0
    DR.set_hd_letterbox true
    print_props args, "== TEST 3 =="
  end

  def test_4 args
    DR.set_window_fullscreen false
    DR.set_window_size 1920, 540
    DR.set_hd_max_scale 0
    DR.set_hd_letterbox true
    print_props args, "== TEST 4 =="
  end

  def test_5 args
    DR.set_window_fullscreen false
    DR.maximize_window
    DR.set_hd_max_scale 100
    print_props args, "== TEST 5 =="
  end

  def test_6 args
    DR.set_window_fullscreen false
    DR.maximize_window
    DR.set_hd_max_scale 150
    print_props args, "== TEST 6 =="
  end

  def test_7 args
    DR.set_window_fullscreen true
    DR.set_hd_max_scale 400
    print_props args, "== TEST 7 =="
  end

  def test_8 args
    DR.set_window_fullscreen true
    DR.set_hd_max_scale 0
    print_props args, "== TEST 8 =="
  end

  def test_9 args
    DR.set_window_fullscreen false
    DR.set_window_size 1280, 720
    DR.set_hd_max_scale 0
    DR.set_hd_letterbox true
    print_props args, "== TEST 9 =="
  end

  def test_10 args
    DR.set_window_fullscreen false
    DR.set_window_scale 1
    DR.set_hd_max_scale 0
    DR.set_hd_letterbox true
    print_props args, "== TEST 10 =="
  end

  def test_11 args
    DR.set_window_fullscreen false
    DR.set_window_scale 0.5, 9, 16
    DR.set_hd_max_scale 0
    DR.set_hd_letterbox true
    print_props args, "== TEST 11 =="
  end

  def test_12 args
    DR.set_window_fullscreen false
    DR.set_window_scale 1.5, 32, 9
    DR.set_hd_max_scale 0
    DR.set_hd_letterbox true
    print_props args, "== TEST 12 =="
  end

  def test_13 args
    DR.set_window_fullscreen false
    DR.set_window_scale 1
    DR.set_hd_max_scale 0
    DR.set_hd_letterbox true
    print_props args, "== TEST 13 =="
  end

  def props
    [
      "high_dpi_scale: #{Grid.high_dpi_scale}",
      "native_scale: #{Grid.native_scale}",
      "hd_max_scale: #{Cvars["game_metadata.hd_max_scale"].value}",
      "native_scale: #{Grid.native_scale}",
      "render_scale: #{Grid.render_scale}",
      "texture_scale: #{Grid.texture_scale}",
      "texture_scale_enum: #{Grid.texture_scale_enum}",
      "letterbox?: #{Grid.letterbox?}",
      "allscreen_w: #{Grid.allscreen_w}",
      "allscreen_h: #{Grid.allscreen_h}",
      "allscreen_offset_x: #{Grid.allscreen_offset_x}",
      "allscreen_offset_y: #{Grid.allscreen_offset_y}",
    ]
  end

  def print_props args, title
    DR.on_tick_count Kernel.tick_count + 120 do
      puts title
      props.each { |prop| puts prop }
      if (args.state.current_test_index - 1) > 0
        DR.notify "test_#{args.state.current_test_index - 1} complete (see console output)."
      end
      args.state.is_running = :no
    end
  end
end
