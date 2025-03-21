require 'app/level_editor.rb'
require 'app/root_scene.rb'
require 'app/camera.rb'

def tick args
  $root_scene ||= RootScene.new args
  $root_scene.args = args
  $root_scene.tick
end

def reset
  $root_scene = nil
end

GTK.reset
