def tick args
  if Kernel.tick_count == 60
    GTK.notify("Performing HTTP/POST to https://httpbin.org/anything")
    url = "https://httpbin.org/anything"
    content = '{ "message": "hello world" }'
    args.state.auth_result ||= GTK.http_post_body(url, content,
                                                  [
                                                    "Content-Type: application/json",
                                                    "Content-Length: #{content.length.to_i}"
                                                  ])
  end

  if Kernel.tick_count > 120
    if args.state.auth_result.complete
      args.state.auth_result.response_data.to_s.wrapped_lines(80).each_with_index do |l, i|
        args.outputs.labels << { x: 8,
                                 y: 700,
                                 text: l,
                                 anchor_x: 0,
                                 anchor_y: 0.5 + (i * 1) }
      end
    end
  end
end
