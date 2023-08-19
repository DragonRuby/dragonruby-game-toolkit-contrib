def build_c_extension
  v = Time.now.to_i
  $gtk.exec("cd ./mygame && (env SUFFIX=#{v} sh ./pre.sh 2>&1 | tee ./build-results.txt)")
  build_output = $gtk.read_file("build-results.txt")
  {
    dll_name: "ext_#{v}",
    build_output: build_output
  }
end

def tick args
  # sets console command when sample app initially opens
  if Kernel.global_tick_count == 0
    results = build_c_extension
    dll = results.dll_name
    $gtk.dlopen(dll)
    puts ""
    puts ""
    puts "========================================================="
    puts "* INFO: Static Sprites, Classes, Draw Override"
    puts "* INFO: Please specify the number of sprites to render."
    args.gtk.console.set_command "reset_with count: 100"
  end

  args.state.star_count ||= 0

  # init
  if args.state.tick_count == 0
    args.state.stars = args.state.star_count.map { |i| Star.new }
    args.outputs.static_sprites << args.state.stars
  end

  # render framerate
  args.outputs.background_color = [0, 0, 0]
  args.outputs.primitives << args.gtk.current_framerate_primitives
end

# resets game, and assigns star count given by user
def reset_with count: count
  $gtk.reset
  $gtk.args.state.star_count = count
end

$gtk.reset
