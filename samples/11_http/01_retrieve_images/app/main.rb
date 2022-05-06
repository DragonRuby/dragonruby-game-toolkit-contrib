$gtk.register_cvar 'app.warn_seconds', "seconds to wait before starting", :uint, 11

def tick args
  args.outputs.background_color = [0, 0, 0]

  # Show a warning at the start.
  args.state.warning_debounce ||= args.cvars['app.warn_seconds'].value * 60
  if args.state.warning_debounce > 0
    args.state.warning_debounce -= 1
    args.outputs.labels << [640, 600, "This app shows random images from the Internet.", 10, 1, 255, 255, 255]
    args.outputs.labels << [640, 500, "Quit in the next few seconds if this is a problem.", 10, 1, 255, 255, 255]
    args.outputs.labels << [640, 350, "#{(args.state.warning_debounce / 60.0).to_i}", 10, 1, 255, 255, 255]
    return
  end

  args.state.download_debounce ||= 0   # start immediately, reset to non zero later.
  args.state.photos ||= []

  # Put a little pause between each download.
  if args.state.download.nil?
    if args.state.download_debounce > 0
      args.state.download_debounce -= 1
    else
      args.state.download = $gtk.http_get 'https://picsum.photos/200/300.jpg'
    end
  end

  if !args.state.download.nil?
    if args.state.download[:complete]
      if args.state.download[:http_response_code] == 200
        fname = "sprites/#{args.state.photos.length}.jpg"
        $gtk.write_file fname, args.state.download[:response_data]
        args.state.photos << [ 100 + rand(1080), 500 - rand(480), fname, rand(80) - 40 ]
      end
      args.state.download = nil
      args.state.download_debounce = (rand(3) + 2) * 60
    end
  end

  # draw any downloaded photos...
  args.state.photos.each { |i|
    args.outputs.primitives << [i[0], i[1], 200, 300, i[2], i[3]].sprite
  }

  # Draw a download progress bar...
  args.outputs.primitives << [0, 0, 1280, 30, 0, 0, 0, 255].solid
  if !args.state.download.nil?
    br = args.state.download[:response_read]
    total = args.state.download[:response_total]
    if total != 0
      pct = br.to_f / total.to_f
      args.outputs.primitives << [0, 0, 1280 * pct, 30, 0, 0, 255, 255].solid
    end
  end
end
