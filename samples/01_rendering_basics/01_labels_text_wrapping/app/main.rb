def tick args
  # create a really long string
  really_long_string =  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. In vulputate viverra metus et vehicula. Aenean quis accumsan dolor. Nulla tempus, ex et lacinia elementum, nisi felis ullamcorper sapien, sed sagittis sem justo eu lectus. Etiam ut vehicula lorem, nec placerat ligula. Duis varius ultrices magna non sagittis. Aliquam et sem vel risus viverra hendrerit. Maecenas dapibus congue lorem, a blandit mauris feugiat sit amet."
  really_long_string += "\n\n"
  really_long_string += "Sed quis metus lacinia mi dapibus fermentum nec id nunc. Donec tincidunt ante a sem bibendum, eget ultricies ex mollis. Quisque venenatis erat quis pretium bibendum. Pellentesque vel laoreet nibh. Cras gravida nisi nec elit pulvinar, in feugiat leo blandit. Quisque sodales quam sed congue consequat. Vivamus placerat risus vitae ex feugiat viverra. In lectus arcu, pellentesque vel ipsum ac, dictum finibus enim. Quisque consequat leo in urna dignissim, eu tristique ipsum accumsan. In eros sem, iaculis ac rhoncus eu, laoreet vitae ipsum. In sodales, ante eu tempus vehicula, mi nulla luctus turpis, eu egestas leo sapien et mi."

  # length of characters on line
  max_character_length = 80

  # API: String.wrapped_lines(string, max_character_length)
  long_strings_split = String.wrapped_lines really_long_string,
                                            max_character_length

  # render a label for each line and offset by the index value
  # setting the anchor_y for a label will offset the text by its
  # height
  args.outputs.labels << long_strings_split.map_with_index do |s, i|
    {
      x: 60,
      y: 720 - 60,
      anchor_y: i,
      text: s
    }
  end
end
