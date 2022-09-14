# APIs covered:
#   args.gtk.write_file "file-1.txt", args.state.tick_count.to_s
#   args.gtk.append_file "file-1.txt", args.state.tick_count.to_s

#   stat = args.gtk.stat_file "file-1.txt"

#   contents = args.gtk.read_file "file-1.txt"

#   args.gtk.delete_file "file-1.txt"
#   args.gtk.delete_file_if_exist "file-1.txt"

#   root_files = args.gtk.list_files ""
#   app_files  = args.gtk.list_files "app"

def tick args
  # create buttons
  args.state.buttons ||= [
    create_button(args, id: :write_file_1,  row: 0, col: 0, text: "write file-1.txt"),
    create_button(args, id: :append_file_1, row: 1, col: 0, text: "append file-1.txt"),
    create_button(args, id: :delete_file_1, row: 2, col: 0, text: "delete file-1.txt"),

    create_button(args, id: :read_file_1,   row: 0, col: 3, text: "read file-1.txt"),
    create_button(args, id: :stat_file_1,   row: 1, col: 3, text: "stat file-1.txt"),
    create_button(args, id: :list_files,    row: 2, col: 3, text: "list files"),
  ]

  # render button's border and label
  args.outputs.primitives << args.state.buttons.map do |b|
    b.primitives
  end

  # render center label if the text is set
  if args.state.center_label_text
    long_string = args.state.center_label_text
    max_character_length = 80
    long_strings_split = args.string.wrapped_lines long_string, max_character_length
    line_height = 23
    offset = (long_strings_split.length / 2) * line_height
    args.outputs.labels << long_strings_split.map_with_index do |s, i|
      {
        x: 400,
        y: 60.from_top - (i * line_height),
        text: s
      }
    end
  end

  # if the mouse is clicked, see if the mouse click intersected
  # with a button
  if args.inputs.mouse.click
    button = args.state.buttons.find do |b|
      args.inputs.mouse.intersect_rect? b
    end

    # update the center label text based on button clicked
    case button.id
    when :write_file_1
      args.gtk.write_file("file-1.txt", args.state.tick_count.to_s + "\n")

      args.state.center_label_text = ""
      args.state.center_label_text += "* Success (#{args.state.tick_count}):\n"
      args.state.center_label_text += "  Click \"read file-1.txt\" to see the contents.\n"
      args.state.center_label_text += "\n"
      args.state.center_label_text += "** Sample Code\n"
      args.state.center_label_text += "   args.gtk.write_file(\"file-1.txt\", args.state.tick_count.to_s + \"\\n\")\n"
    when :append_file_1
      args.gtk.append_file("file-1.txt", args.state.tick_count.to_s + "\n")

      args.state.center_label_text = ""
      args.state.center_label_text += "* Success (#{args.state.tick_count}):\n"
      args.state.center_label_text += "  Click \"read file-1.txt\" to see the contents.\n"
      args.state.center_label_text += "\n"
      args.state.center_label_text += "** Sample Code\n"
      args.state.center_label_text += "   args.gtk.append_file(\"file-1.txt\", args.state.tick_count.to_s + \"\\n\")\n"
    when :stat_file_1
      stat = args.gtk.stat_file "file-1.txt"

      args.state.center_label_text = ""
      args.state.center_label_text += "* Stat File (#{args.state.tick_count})\n"
      args.state.center_label_text += "#{stat || "nil (file does not exist)"}"
      args.state.center_label_text += "\n"
      args.state.center_label_text += "\n"
      args.state.center_label_text += "** Sample Code\n"
      args.state.center_label_text += "   args.gtk.stat_files(\"file-1.txt\")\n"
    when :read_file_1
      contents = args.gtk.read_file("file-1.txt")

      args.state.center_label_text = ""
      if contents
        args.state.center_label_text += "* Contents (#{args.state.tick_count}):\n"
        args.state.center_label_text += contents
        args.state.center_label_text += "\n"
        args.state.center_label_text += "** Sample Code\n"
        args.state.center_label_text += "   contents = args.gtk.read_file(\"file-1.txt\")\n"
      else
        args.state.center_label_text += "* Contents (#{args.state.tick_count}):\n"
        args.state.center_label_text += "Contents of file was nil. Click stat file-1.txt for file information."
        args.state.center_label_text += "\n"
        args.state.center_label_text += "** Sample Code\n"
        args.state.center_label_text += "   contents = args.gtk.read_file(\"file-1.txt\")\n"
      end
    when :delete_file_1
      args.state.center_label_text = ""

      if args.gtk.stat_file "file-1.txt"
        args.gtk.delete_file "file-1.txt"
        args.state.center_label_text += "* Delete File\n"
        args.state.center_label_text += "file-1.txt was deleted. Click \"list files\" or \"stat file-1.txt\" for more info."
        args.state.center_label_text += "\n"
        args.state.center_label_text += "\n"
        args.state.center_label_text += "** Sample Code\n"
        args.state.center_label_text += "   args.gtk.delete_file(\"file-1.txt\")\n"
      else
        args.state.center_label_text = ""
        args.state.center_label_text += "* Delete File\n"
        args.state.center_label_text += "File does not exist. Click \"write file-1.txt\" or \"append file-1.txt\" to create file."
        args.state.center_label_text += "\n"
        args.state.center_label_text += "\n"
        args.state.center_label_text += "** Sample Code\n"
        args.state.center_label_text += "   if args.gtk.stat_file(\"file-1.txt\") ...\n"
      end
    when :list_files
      root_files = args.gtk.list_files ""
      app_files  = args.gtk.list_files "app"

      args.state.center_label_text = ""
      args.state.center_label_text += "** Root Files (#{args.state.tick_count}):\n"
      args.state.center_label_text += root_files.join "\n"
      args.state.center_label_text += "\n"
      args.state.center_label_text += "\n"
      args.state.center_label_text += "** App Files (#{args.state.tick_count}):\n"
      args.state.center_label_text += app_files.join "\n"
      args.state.center_label_text += "\n"
      args.state.center_label_text += "\n"
      args.state.center_label_text += "** Sample Code\n"
      args.state.center_label_text += "   root_files = args.gtk.list_files(\"\")\n"
      args.state.center_label_text += "   app_files = args.gtk.list_files(\"app\")\n"
    end
  end
end

def create_button args, id:, row:, col:, text:;
  # args.layout.rect(row:, col:, w:, h:) is method that will
  # return a rectangle inside of a grid with 12 rows and 24 columns
  rect = args.layout.rect row: row, col: col, w: 3, h: 1

  # get senter of rect for label
  center = args.geometry.rect_center_point rect

  {
    id: id,
    x: rect.x,
    y: rect.y,
    w: rect.w,
    h: rect.h,
    primitives: [
      {
        x: rect.x,
        y: rect.y,
        w: rect.w,
        h: rect.h,
        primitive_marker: :border
      },
      {
        x: center.x,
        y: center.y,
        text: text,
        size_enum: -2,
        alignment_enum: 1,
        vertical_alignment_enum: 1,
        primitive_marker: :label
      }
    ]
  }
end

$gtk.reset
