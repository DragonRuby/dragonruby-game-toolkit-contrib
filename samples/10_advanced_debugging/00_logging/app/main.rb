def tick args
  args.outputs.background_color = [255, 255, 255, 0]
  if args.state.tick_count == 0
    args.gtk.log_spam "log level spam"
    args.gtk.log_debug "log level debug"
    args.gtk.log_info "log level info"
    args.gtk.log_warn "log level warn"
    args.gtk.log_error "log level error"
    args.gtk.log_unfiltered "log level unfiltered"
    puts "This is a puts call"
    args.gtk.console.show
  end

  if args.state.tick_count == 60
    puts "This is a puts call on tick 60"
  elsif args.state.tick_count == 120
    puts "This is a puts call on tick 120"
  end
end
