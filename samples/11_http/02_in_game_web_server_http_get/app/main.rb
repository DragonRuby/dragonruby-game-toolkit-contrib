def tick args
  args.state.reqnum ||= 0
  # by default the embedded webserver is disabled in a production build
  # to enable the http server in a production build you need to:
  # - update metadata/cvars.txt
  # - manually start the server up with enable_in_prod set to true:
  GTK.start_server! port: 3000, enable_in_prod: true
  args.outputs.background_color = [0, 0, 0]
  args.outputs.labels << { x: 640,
                           y: 360,
                           text: "Point your web browser at http://localhost:#{args.state.port}/",
                           size_px: 30,
                           anchor_x: 0.5,
                           anchor_y: 0.5 }

  args.outputs.labels << { x: 640,
                           y: 360,
                           text: "See metadata/cvars.txt for webserer configuration requirements.",
                           size_px: 30,
                           anchor_x: 0.5,
                           anchor_y: 1.5 }

  if Kernel.tick_count == 1
    GTK.openurl "http://localhost:3000"
  end

  args.inputs.http_requests.each { |req|
    puts("METHOD: #{req.method}");
    puts("URI: #{req.uri}");
    puts("HEADERS:");
    req.headers.each { |k,v| puts("  #{k}: #{v}") }

    if (req.uri == '/')
      # headers and body can be nil if you don't care about them.
      # If you don't set the Content-Type, it will default to
      #  "text/html; charset=utf-8".
      # Don't set Content-Length; we'll ignore it and calculate it for you
      args.state.reqnum += 1
      req.respond 200, "<html><head><title>hello</title></head><body><h1>This #{req.method} was request number #{args.state.reqnum}!</h1></body></html>\n", { 'X-DRGTK-header' => 'Powered by DragonRuby!' }
    else
      req.reject
    end
  }
end
