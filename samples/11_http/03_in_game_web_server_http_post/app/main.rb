def tick args
  # defaults
  args.state.post_button      = args.layout.rect(row: 0, col: 0, w: 5, h: 1).merge(text: "execute http_post")
  args.state.post_body_button = args.layout.rect(row: 1, col: 0, w: 5, h: 1).merge(text: "execute http_post_body")
  args.state.request_to_s ||= ""
  args.state.request_body ||= ""

  # render
  args.state.post_button.yield_self do |b|
    args.outputs.borders << b
    args.outputs.labels  << b.merge(text: b.text,
                                    y:    b.y + 30,
                                    x:    b.x + 10)
  end

  args.state.post_body_button.yield_self do |b|
    args.outputs.borders << b
    args.outputs.labels  << b.merge(text: b.text,
                                    y:    b.y + 30,
                                    x:    b.x + 10)
  end

  draw_label args, 0,  6, "Request:", args.state.request_to_s
  draw_label args, 0, 14, "Request Body Unaltered:", args.state.request_body

  # input
  if args.inputs.mouse.click
    # ============= HTTP_POST =============
    if (args.inputs.mouse.inside_rect? args.state.post_button)
      # ========= DATA TO SEND ===========
      form_fields = { "userId" => "#{Time.now.to_i}" }
      # ==================================

      args.gtk.http_post "http://localhost:9001/testing",
                         form_fields,
                         ["Content-Type: application/x-www-form-urlencoded"]

      args.gtk.notify! "http_post"
    end

    # ============= HTTP_POST_BODY =============
    if (args.inputs.mouse.inside_rect? args.state.post_body_button)
      # =========== DATA TO SEND ==============
      json = "{ \"userId\": \"#{Time.now.to_i}\"}"
      # ==================================

      args.gtk.http_post_body "http://localhost:9001/testing",
                              json,
                              ["Content-Type: application/json", "Content-Length: #{json.length}"]

      args.gtk.notify! "http_post_body"
    end
  end

  # calc
  args.inputs.http_requests.each do |r|
    puts "#{r}"
    if r.uri == "/testing"
      puts r
      args.state.request_to_s = "#{r}"
      args.state.request_body = r.raw_body
      r.respond 200, "ok"
    end
  end
end

def draw_label args, row, col, header, text
  label_pos = args.layout.rect(row: row, col: col, w: 0, h: 0)
  args.outputs.labels << "#{header}\n\n#{text}".wrapped_lines(80).map_with_index do |l, i|
    { x: label_pos.x, y: label_pos.y - (i * 15), text: l, size_enum: -2 }
  end
end
