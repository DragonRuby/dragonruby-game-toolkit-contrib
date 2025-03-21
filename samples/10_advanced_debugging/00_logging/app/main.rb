def tick args
  args.outputs.background_color = [255, 255, 255, 0]
  if Kernel.tick_count == 0
    GTK.log_spam "log level spam"
    GTK.log_debug "log level debug"
    GTK.log_info "log level info"
    GTK.log_warn "log level warn"
    GTK.log_error "log level error"
    GTK.log_unfiltered "log level unfiltered"
    puts "This is a puts call"
    GTK.console.show
  end

  if Kernel.tick_count == 60
    puts "This is a puts call on tick 60"
  elsif Kernel.tick_count == 120
    puts "This is a puts call on tick 120"
  end
end
