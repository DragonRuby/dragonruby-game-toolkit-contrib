GTK.register_cvar 'app.warn_seconds', "seconds to wait before starting", :uint, 6

def tick args
  args.outputs.background_color = [0, 0, 0]

  args.state.download_debounce ||= 0   # start immediately, reset to non zero later.
  args.state.photos ||= []
  if args.state.photos.length > 300
    args.state.photos.pop_front
  end

  # Show a warning at the start.
  args.state.warning_debounce ||= args.cvars['app.warn_seconds'].value * 60
  if args.state.warning_debounce > 0
    args.state.warning_debounce -= 1
    args.outputs.labels << { x: 640, y: 600, text: "This app shows random images from the Internet.", size_enum: 10, alignment_enum: 1, r: 255, g: 255, b: 255 }
    args.outputs.labels << { x: 640, y: 500, text: "Quit in the next few seconds if this is a problem.", size_enum: 10, alignment_enum: 1, r: 255, g: 255, b: 255 }
    args.outputs.labels << { x: 640, y: 350, text: "#{(args.state.warning_debounce / 60.0).to_i}", size_enum: 10, alignment_enum: 1, r: 255, g: 255, b: 255 }
    return
  end

  # Put a little pause between each download.
  if args.state.download.nil?
    if args.state.download_debounce > 0
      args.state.download_debounce -= 1
    else
      args.state.download = GTK.http_get 'https://picsum.photos/200/300.jpg'
    end
  end

  if !args.state.download.nil?
    if args.state.download[:complete]
      if args.state.download[:http_response_code] == 200
        fname = "sprites/#{args.state.photos.length}.jpg"
        GTK.write_file fname, args.state.download[:response_data]
        args.state.photos << { x: Numeric.rand(100..1180),
                               y: Numeric.rand(150..570),
                               path: fname,
                               angle: Numeric.rand(-40..40) }
      end
      args.state.download = nil
      args.state.download_debounce = Numeric.rand(30..90)
    end
  end

  # draw any downloaded photos...
  args.state.photos.each { |i|
    args.outputs.primitives << { x: i.x, y: i.y, w: 200, h: 300, path: i.path, angle: i.angle, anchor_x: 0.5, anchor_y: 0.5 }
  }

  # Draw a download progress bar...
  args.outputs.primitives << { x: 0, y: 0, w: 1280, h: 30, r: 0, g: 0, b: 0, a: 255, path: :solid }
  if !args.state.download.nil?
    br = args.state.download[:response_read]
    total = args.state.download[:response_total]
    if total != 0
      pct = br.to_f / total.to_f
      args.outputs.primitives << { x: 0, y: 0, w: 1280 * pct, h: 30, r: 0, g: 0, b: 255, a: 255, path: :solid }
    end
  end
end
