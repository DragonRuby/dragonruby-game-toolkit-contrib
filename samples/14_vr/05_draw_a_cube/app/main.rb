require 'app/tick.rb'

def tick args
  GTK.start_server! port: 9001, enable_in_prod: true
  tick_game args
end
