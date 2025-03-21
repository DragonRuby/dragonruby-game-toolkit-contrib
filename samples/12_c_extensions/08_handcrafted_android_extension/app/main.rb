def boot args
end

def tick args
  if args.inputs.mouse.click && !@dl_opened
    GTK.dlopen("ext")
    @dl_opened = true
  elsif args.inputs.mouse.click
    h = UserDefaults.new
    args.state.user_defaults_exist = true
  end

  if !args.state.user_defaults_exist
    args.outputs.labels << { x: 640, y: 360, text: "click to verify C extension", anchor_x: 0.5, anchor_y: 0.5 }
  else
    args.outputs.labels << { x: 640, y: 360, text: "C extension successfully created", anchor_x: 0.5, anchor_y: 0.5 }
  end
end
