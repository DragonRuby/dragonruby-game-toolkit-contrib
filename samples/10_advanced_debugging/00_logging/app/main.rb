def tick args
  args.outputs.background_color = [255, 255, 255, 0]
  if Kernel.tick_count == 0
    DR.log_spam "log level spam"
    DR.log_debug "log level debug"
    DR.log_info "log level info"
    DR.log_warn "log level warn"
    DR.log_error "log level error"
    DR.log_unfiltered "log level unfiltered"
    puts "This is a puts call"
    DR.console.show
  end

  if Kernel.tick_count == 60
    puts "This is a puts call on tick 60"
  elsif Kernel.tick_count == 120
    puts "This is a puts call on tick 120"
  end
end
