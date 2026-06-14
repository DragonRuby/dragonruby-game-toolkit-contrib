require 'app/tick.rb'

def tick args
  DR.start_server! port: 9001, enable_in_prod: true
  tick_game args
end
