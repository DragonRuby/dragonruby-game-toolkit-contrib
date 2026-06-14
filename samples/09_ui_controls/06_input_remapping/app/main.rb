# sample app demonstrates how you can create a UI for remapping inputs
# for a controller/keyboard

# wrapper game class so we aren't having to pass args.state everywhere
class Game
  attr_dr # this class macro adds args.inputs, outputs, etc to Game

  def initialize
    # default input mappings for keyboard and controller one
    @input_mappings = {
      keyboard: {
        move_left: [:left_arrow],
        move_right: [:right_arrow]
      },
      controller_one: {
        move_left: [:left],
        move_right: [:right]
      }
    }

    # default the current input method to keyboard
    @current_input = :keyboard

    # set the current game mode to "playing the game" (ability to move the player)
    @mode = :game

    # initialized the player
    @player = {
      x: 640, y: 360, w: 80, h: 80,
      path: :solid,
      r: 80, g: 128, b: 128,
      anchor_x: 0.5,
      anchor_y: 0.5
    }
  end

  def tick
    # if the mode is game, then tick_game, otherwise tick_remap
    if @mode == :game
      tick_game
    elsif @mode == :remap
      tick_remap
    end

    # render remap_buttons
    args.outputs.primitives << remap_button_prefabs

    # render the player
    args.outputs.primitives << @player
  end

  def tick_game
    # determine what the current input is based on what was last used
    if args.inputs.last_active == :controller
      @current_input = :controller_one
    elsif args.inputs.last_active == :keyboard
      @current_input = :keyboard
    end

    # check the input mappings for the named action
    if activated? :move_left
      @player.x -= 5
    elsif activated? :move_right
      @player.x += 5
    end

    # if the mouse is used an the click intersects
    # with an input mapping button, then set the mode to "remapping mode"
    # capture which mapping will be updated
    if args.inputs.mouse.key_down.left
      button = remap_buttons.find { |b| args.inputs.mouse.inside_rect?(b.rect) }
      if button
        @mode = :remap
        @remap_input_name = button.input_name
        @remap_input_type = button.input_type
      end
    end
  end

  def tick_remap
    # if we are in remapping mode, get all keys that were pressed for
    # the input we are attempting to update
    keys = inputs.send(@remap_input_type).key_down.truthy_keys

    # if keys are returned, then update the mapping table with the new key alias
    # after updating the mapping, set the game back to "playing the game" mode
    if keys.length > 0
      @input_mappings[@remap_input_type][@remap_input_name] = keys
      @mode = :game
    end
  end

  # method returns true if the mapping for the pressed/held key, for the current input is true
  def activated? input_name
    # a reminder of what input mappings looks like:
    # @input_mappings = {
    #   keyboard: {
    #     move_left: [:left_arrow],
    #     move_right: [:right_arrow]
    #   },
    #   controller_one: {
    #     move_left: [:left],
    #     move_right: [:right]
    #   }
    # }
    @input_mappings[@current_input][input_name].any? { |k| inputs.send(@current_input).key_down_or_held?(k) }
  end

  def remap_buttons
    # create button information by traversing the current mapping
    @input_mappings.flat_map do |input_type, input_names|
      # .flat_map in combination with .map will give us a flattened list of buttons
      # from the input_mappings hash
      input_names.map do |input_name, input_keys|
        {
          input_keys: input_keys,
          input_type: input_type,
          input_name: input_name
        }
      end
    end.map_with_index do |h, i|
      # now that we have the hash with pertinant metadata,
      # use the Layout apis to generate rectagles (hit boxes) and text for the button
      {
        rect: Layout.rect(row: i, col: 0, w: 12, h: 1),
        text: "#{h.input_type} #{h.input_name}: #{h.input_keys}",
        **h
      }
    end
  end

  def remap_button_prefabs
    # take the rects from remap buttons and generate the
    # prefab
    remap_buttons.map do |b|
      # if the mode is "remapping mode", then change the color of the button
      # so we know which key we are attempting to remap
      color = if @mode == :remap && @remap_input_name == b.input_name && @remap_input_type == b.input_type
                { r: 80, g: 80, b: 30 }
              else
                { r: 30, g: 30, b: 30 }
              end
      [
        { **b.rect, path: :solid, **color }, # background border
        { **b.rect.center, text: "#{b.text}", anchor_x: 0.5, anchor_y: 0.5, r: 255, g: 255, b: 255 } # text/label of the button
      ]
    end
  end
end

def boot args
  args.state = {}
end

def tick args
  $game ||= Game.new
  $game.args = args
  $game.tick
end

def reset args
  $game = nil
end

DR.reset
