def boot args
  GTK.dlopen 'ext'
end

def tick args
  if Kernel.tick_count == 0
    hello = Hello.new
    puts hello.get_message("John Doe")
    bye = Bye.new
    puts bye.get_message("John Doe")
  end
end
