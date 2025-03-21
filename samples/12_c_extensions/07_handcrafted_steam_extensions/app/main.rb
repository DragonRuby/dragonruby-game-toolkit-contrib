def boot args
  GTK.dlopen 'ext'
  $steam = Steam.new
  $steam.init_api
end

def tick args
  if Kernel.tick_count == 0
    puts "Retrieving user name."
    puts $steam.get_user_name
  end
end
