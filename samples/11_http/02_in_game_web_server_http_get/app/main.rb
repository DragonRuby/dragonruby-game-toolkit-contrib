def tick args
  args.state.port ||= 3000
  args.state.reqnum ||= 0
  # by default the embedded webserver runs on port 9001 (the port number is over 9000) and is disabled in a production build
  # to enable the http server in a production build, you need to manually start
  # the server up:
  args.gtk.start_server! port: args.state.port, enable_in_prod: true
  args.outputs.background_color = [0, 0, 0]
  args.outputs.labels << [640, 600, "Point your web browser at http://localhost:#{args.state.port}/", 10, 1, 255, 255, 255]

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
