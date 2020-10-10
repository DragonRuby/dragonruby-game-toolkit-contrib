# You can customize the buttons that show up in the Console.
class GTK::Console::Menu
  # STEP 1: Override the custom_buttons function.
  def custom_buttons
    [
      (button id: :yay,
              # row for button
              row: 3,
              # column for button
              col: 10,
              # text
              text: "I AM CUSTOM",
              # when clicked call the custom_button_clicked function
              method: :custom_button_clicked),

      (button id: :yay,
              # row for button
              row: 3,
              # column for button
              col: 9,
              # text
              text: "CUSTOM ALSO",
              # when clicked call the custom_button_also_clicked function
              method: :custom_button_also_clicked)
    ]
  end

  # STEP 2: Define the function that should be called.
  def custom_button_clicked
    log "* INFO: I AM CUSTOM was clicked!"
  end

  def custom_button_also_clicked
    log "* INFO: Custom Button Clicked at #{Kernel.global_tick_count}!"

    all_buttons_as_string = $gtk.console.menu.buttons.map do |b|
      <<-S.strip
** id: #{b[:id]}
:PROPERTIES:
:id:     :#{b[:id]}
:method: :#{b[:method]}
:text:   #{b[:text]}
:END:
S
    end.join("\n")

    log <<-S
* INFO: Here are all the buttons:
#{all_buttons_as_string}
S
  end
end

def tick args
  args.outputs.labels << [args.grid.center.x, args.grid.center.y,
                          "Open the DragonRuby Console to see the custom menu items.",
                          0, 1]
end
