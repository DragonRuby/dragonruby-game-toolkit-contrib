MAILBOX_SAVE_PATH = 'app/mailbox.rb'

def tick args
  args.gtk.suppress_mailbox = false
  args.state.send_to_mailbox = [220, 360, 200, 50]
  args.state.clear_mailbox   = [220, 300, 200, 50]
  args.state.mailbox_values ||= []
  args.outputs.borders << args.state.send_to_mailbox
  args.outputs.borders << args.state.clear_mailbox
  args.outputs.labels << [230, 390, "Send to Mailbox"]
  args.outputs.labels << [230, 325, "Clear Mailbox"]

  if args.inputs.mouse.click
     if args.inputs.mouse.click.point.inside_rect?(args.state.send_to_mailbox)
       current_text = args.gtk.read_file("app/mailbox.rb") || ''
       code =  "$gtk.args.state.mailbox_values << 'code written to file called mailbox.rb at tick_count #{args.state.tick_count}'"
       args.gtk.write_file(MAILBOX_SAVE_PATH, current_text + "\n" + code)
     elsif args.inputs.mouse.click.point.inside_rect?(args.state.clear_mailbox)
       current_text = args.gtk.read_file("app/mailbox.rb") || ''
       code =  "$gtk.args.state.mailbox_values = []"
       args.gtk.write_file(MAILBOX_SAVE_PATH, current_text + "\n" + code)
     end
  end

  args.state.mailbox_values.each_with_index.map do |v, i|
    args.outputs.labels << [640, 680 + i * -30, v]
  end
end
