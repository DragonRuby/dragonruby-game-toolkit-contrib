# this reference implementation shows how to construct a game with multiple scenes,
# with scene transition animations, multiple orientations, and multiple device inputs

# some prerequisite knowledge of the following concepts will help a
# lot in understanding how all of this is put together (see previous
# sample apps in 07_advanced_rendering and 07_advanced_rendering_hd
# for examples of these concepts in isolation):
# - Render Targets
# - Custom Blendmodes
# - Layout
# - Easing

def boot args
  args.state = {}
end

def tick args
  $root_scene ||= RootScene.new args
  $root_scene.args = args
  $root_scene.tick
end

def reset args
  $root_scene = nil
end

# this is the default scene structure that every child scene inherits from
class Scene
  attr_dr

  attr :activate_at, :deactivate_at

  # a scene must have an idea
  def id = raise "Set the scene's id by overriding the id method on #{self.class}."

  # when a scene transitions in, this function will be called on the scene
  def activate! = puts "Scene #{id} activated. Override activate! on #{self.class} to add custom behavior."

  # when a scene transitions out, this function will be called on the scene
  def deactivate! = puts "Scene #{id} deactivated. Override deactivate! on #{self.class} to add custom behavior."

  # this is invoked for the current active scene
  def tick = puts "Scene #{id} tick. Override tick on #{self.class} to add custom behavior."

  # this function returns primitives the scene created so that they can be rendered
  def primitives = puts "Scene #{id} primitives. Override primitives on #{self.class} to add custom behavior."

  # this function returns whether the scene is currently active (used
  # to gate input and ticking)
  def active?
    activate_at && !deactivate_at
  end

  # signifies that the scene is ready to accept inputs
  def accepts_input?
    active? && state.current_scene_at.elapsed_time > 30
  end
end

# this is the root scene that controls the orchestration of the UI
class RootScene
  attr_dr

  def initialize args
    # construct all the scenes and set the initial scene to level select
    @all_scenes = {
      level_select: LevelSelectScene.new,
      game: LevelScene.new
    }
    args.state.current_scene = :level_select
    args.state.current_scene_at = Kernel.tick_count
    @all_scenes[args.state.current_scene].activate_at = Kernel.tick_count
    @all_scenes[args.state.current_scene].deactivate_at = nil

    # these instance variables are used to control the scene transition animation
    @current_scene_rect = current_scene_start_rect
    @previous_scene_rect = previous_scene_start_rect
  end

  # this is the main tick function for the root scene.
  def tick
    # we capture what the current scene before invoking the active
    # scene's tick function so that we can verify that the active
    # scene didn't change mid-tick without using the proper
    # state.next_scene mechanism
    current_scene_before = args.state.current_scene

    # this function handles the re-rendering of render targets if the
    # orientation changes
    resize

    # this is where we invoke relevant tick functions for the current and previous scenes
    calc

    # this is where we handle scene changes and rendering of the
    # current scene's primitives
    render

    raise "Scene changed mid tick. Use state.next_scene." if state.current_scene != current_scene_before

    # after that we handle scene activation and deactivation
    tick_scene_change
  end

  def resize
    # in the event of an orientation change, we want to invalide the
    # current render targets given the new sizes that the Grid class will provide
    if args.events.resize_occurred
      @current_scene_rect = current_scene_end_rect
    end

    if args.events.resize_occurred
      @previous_scene_rect = previous_scene_end_rect
    end
  end

  def calc
    # set the args for the current and previous scenes and invoke
    # their tick functions
    current_scene.args = args
    current_scene.tick

    # previous scene may not exist if it's the initial load, or if
    # enough time has elapsed since the last scene change, so we use safe navigation operator here
    previous_scene&.args = args
    previous_scene&.tick
  end

  def render
    # set the background color
    outputs.background_color = DawnBringer::BLACK

    # initialize the previous_scene and current_scene render targets
    outputs[:previous_scene].set w: Grid.allscreen_w,
                                 h: Grid.allscreen_h,
                                 background_color: [0, 0, 0, 0]

    outputs[:current_scene].set w: Grid.allscreen_w,
                                h: Grid.allscreen_h,
                                background_color: [0, 0, 0, 0]

    # render the previous_scene and current_scene primitives to their respective render targets
    outputs[:previous_scene].primitives << previous_scene&.primitives
    outputs[:current_scene].primitives << current_scene.primitives

    # render previous and next scene to the top level outputs
    # the previous_scene_rect and current_scene_rect functions will
    # return rects that are used to create a scene transition
    # animation
    outputs.primitives << { **previous_scene_rect, path: :previous_scene, a: previous_scene_alpha }
    outputs.primitives << { **current_scene_rect, path: :current_scene, a: current_scene_alpha }

    # debug primitives to visualize control locations
    outputs.primitives << Layout.debug_primitives(invert_colors: true, a: 32)
  end

  def tick_scene_change
    # if state.next_scene is set, that means the active scene has requested a scene change
    if state.next_scene
      state.previous_scene = state.current_scene

      # for the current scene we want to invoke deactivation logic immediately
      @all_scenes[state.current_scene]&.args = args
      @all_scenes[state.current_scene]&.activate_at = nil
      @all_scenes[state.current_scene]&.deactivate_at = Kernel.tick_count
      @all_scenes[state.current_scene]&.deactivate!

      # after that we set the new scene and reset the scene transition animation timers and rects
      state.current_scene = state.next_scene
      state.current_scene_at = Kernel.tick_count
      @current_scene_rect = current_scene_start_rect
      @previous_scene_rect = previous_scene_start_rect

      state.next_scene = nil

      @all_scenes[state.current_scene].args = args
      @all_scenes[state.current_scene].activate_at = Kernel.tick_count
      @all_scenes[state.current_scene].deactivate_at = nil
      @all_scenes[state.current_scene].activate!
    end
  end

  # these represent the start and end locations for the scene
  # transitions (the key value in these rects is the y value, which
  # creates a vertical wipe transition, but you can modify these to
  # create different transitions)
  def current_scene_end_rect
    { x: Grid.allscreen_x, y: Grid.allscreen_y, w: Grid.allscreen_w, h: Grid.allscreen_h }
  end

  def current_scene_start_rect
    { x: Grid.allscreen_x, y: -Grid.allscreen_h, w: Grid.allscreen_w, h: Grid.allscreen_h }
  end

  def previous_scene_end_rect
    { x: Grid.allscreen_x, y: Grid.allscreen_h, w: Grid.allscreen_w, h: Grid.allscreen_h }
  end

  def previous_scene_start_rect
    { x: Grid.allscreen_x, y: Grid.allscreen_y, w: Grid.allscreen_w, h: Grid.allscreen_h }
  end

  # this is the easing function that gives us the percentage for how
  # far along the scene transition animation is, which is used in the
  # current_scene_rect and previous_scene_rect functions to return the
  # appropriate rect for the current frame
  def current_scene_rect_prec
    Easing.smooth_stop(start_at: state.current_scene_at,
                       duration: 30,
                       tick_count: Kernel.tick_count,
                       power: 2)
  end

  def previous_scene_rect_perc
    Easing.smooth_stop(start_at: state.current_scene_at,
                       duration: 30,
                       tick_count: Kernel.tick_count,
                       power: 2)
  end

  # we use Geometry.lerp_rect to return a rect that is the appropriate
  # percentage between the start and end rects for the current scene
  # transition animation
  def current_scene_rect
    Geometry.lerp_rect(current_scene_start_rect, current_scene_end_rect, current_scene_rect_prec)
  end

  def previous_scene_rect
    Geometry.lerp_rect(previous_scene_start_rect, previous_scene_end_rect, previous_scene_rect_perc)
  end

  # we use a similar easing function to calculate the alpha for the current
  def current_scene_alpha
    255 * Easing.smooth_stop(start_at: state.current_scene_at,
                             duration: 60,
                             tick_count: Kernel.tick_count,
                             power: 2)
  end

  def previous_scene_alpha
    255 * Easing.smooth_stop(start_at: state.current_scene_at,
                             duration: 60,
                             tick_count: Kernel.tick_count,
                             power: 2,
                             flip: true)
  end

  def previous_scene
    # previous scene will return nil after enough time is passed (we
    # don't want to continue invoking tick on a scene that has fully transitioned out)
    return nil if state.current_scene_at.elapsed_time > 120
    @all_scenes[state.previous_scene]
  end

  def current_scene
    @all_scenes[state.current_scene]
  end
end

# this is the level select scene where you can select a level, speed, and difficulty before starting the game
class LevelSelectScene < Scene
  attr :level_button_prefabs, :selected_level_id, :cursor_rect

  def id = :level_select

  def initialize
    # we initialize an array representing the available levels, which
    # is used to generate the level select buttons and determine which
    # level is selected
    @available_levels = 20.map do |i|
      { id: :"level_#{i + 1}", abbreviation: "L#{i + 1}", name: "Level Number ##{i + 1}" }
    end

    # initialize the data structures for level buttons and option buttons
    initialize_level_button_prefabs
    initialize_option_button_prefabs
    select_level! @available_levels.first
    select_level! @available_levels.first
    select_option! @option_button_prefabs.first.id
    activate!
  end

  def initialize_level_button_prefabs
    # this function looks at available levels, orientation, and
    # leverages the Layout.rect api to create the data structures for
    # level buttons (this information will be used for rendering primitives and handling input)
    @level_button_prefabs = @available_levels.map_with_index do |level, i|
      row = i.idiv 5
      col = i % 5

      start_col = if Grid.landscape?
                    3
                  else
                    1
                  end

      rect = Layout.allscreen_rect(row: 3 + row * 2, col: start_col + col * 2, w: 2, h: 2)

      {
        id: level.id, # if of the level this prefab represents
        rect: { **rect }, # hit box of the button
        outer_rect: Geometry.zoom_rect(rect: rect, px: 26), # rect that represents the bounds of the hover indicator
        level: level, # the level data this button represents
      }
    end
  end

  def new_option_button_prefab(id:, value: nil, options: nil, landscape:, portrait:, w:, h:, callback:, keyboard_only: false)
    # orientation layout information for the option buttons
    rect = if Grid.landscape?
             Layout.allscreen_rect(row: landscape.row, col: landscape.col, w: w, h: h)
           else
             Layout.allscreen_rect(row: portrait.row, col: portrait.col, w: w, h: h)
           end

    {
      id: id, # unique identifier for the option button, used for input handling
      value: value, # button's current value (for example, the speed button's value would be "1x", "2x", or "3x" depending on the current selection)
      options: options, # possible values for this option button (used for cycling through options when the button is selected)
      rect: rect, # hit box of the button
      outer_rect: Geometry.zoom_rect(rect: rect, px: 26), # rect that represents the bounds of the hover indicator
      callback: callback, # this is the function that will be called when the button is activated clicked or selected via keyboard
      keyboard_only: keyboard_only # flag that indicates whether this button should only be interactable via keyboard
    }
  end

  def initialize_option_button_prefabs
    # this function creates the button data structurs for each option
    @option_button_prefabs = [
      new_option_button_prefab(id: :speed,
                               value: :"1x",
                               options: [:"1x", :"2x", :"3x"],
                               landscape: { row: 5, col: 15 },
                               portrait: { row: 19, col: 3 },
                               w: 2, h: 2,
                               callback: lambda do |option_button|
                                 # speed button callback function, which cycles through the speed options when the button is activated
                                 index_next = (option_button.options.index(option_button.value) + 1) % option_button.options.length
                                 options_next = option_button.options[index_next]
                                 option_button.value = options_next
                               end),
      new_option_button_prefab(id: :go,
                               value: "Go!",
                               landscape: { row: 5, col: 19 },
                               portrait: { row: 19, col: 7 },
                               w: 2, h: 2,
                               callback: lambda do |option_button|
                                 # go button callback function, which sets the level_selection state and requests a scene change to the game scene when activated
                                 # context that the scene needs is stored in state.level_selection so that the LevelScene can access it when it activates
                                 state.level_selection = {
                                   level: @available_levels.find { |level| level.id == @selected_level_id },
                                   speed: @option_button_prefabs.find { |button| button.id == :speed }.value,
                                   difficulty: @option_button_prefabs.find { |button| button.id == :difficulty }.value
                                 }
                                 # request scene change to game scene
                                 state.next_scene = :game
                               end),
      new_option_button_prefab(id: :difficulty,
                               value: :easy,
                               options: [:easy, :normal, :hard],
                               landscape: { row: 5, col: 17 },
                               portrait: { row: 19, col: 5 },
                               w: 2, h: 2,
                               callback: lambda do |option_button|
                                 # difficulty button callback function, which cycles through the difficulty options when the button is activated
                                 index_next = (option_button.options.index(option_button.value) + 1) % option_button.options.length
                                 options_next = option_button.options[index_next]
                                 option_button.value = options_next
                               end),
      new_option_button_prefab(id: :back,
                               value: "Back",
                               landscape: { row: 7, col: 15 },
                               portrait: { row: 21, col: 3 },
                               w: 6, h: 2,
                               keyboard_only: true,
                               callback: lambda do |option_button|
                                 # back button callback function, which sets the level_selection state and requests a scene change to the game scene when activated
                                 @navigate_mode = :level_buttons
                               end)
    ]
  end

  def activate!
    # when the scene activates, we want to default the navigate mode
    # to the level buttons, select the first level, set the selected
    # option to the first option button, and initialize the cursor
    # position and button fx queue

    # navigation_mode is a flag for keyboard navigation (whether the player is currently navigating the level buttons or the option buttons)
    @navigate_mode = :level_buttons

    # initialize the cursor position to be on the focused button and
    # initialize the button fx queue (used for the hover effect when
    # selecting buttons)
    @cursor_rect = { **focused_button.outer_rect }

    # button fx queue is an array of primitives that are generated
    # when a button is selected, and then processed and rendered each
    # frame to create an expanding border effect. We initialize it to
    # an empty array when the scene activates.
    @button_fx_queue = []
  end

  # this is the tick function for the level select scene, which handles input and updates the cursor position and button fx queue
  def tick
    # we want to re-initialize the button prefabs when a resize occurs
    # so that they can update their rects based on the new orientation
    # and layout, and we also want to update the cursor rect to be on
    # the focused button in the event of a resize so that the cursor
    # doesn't end up in a weird place after an orientation change
    if args.events.resize_occurred
      initialize_level_button_prefabs
      initialize_option_button_prefabs
      @cursor_rect = Geometry.lerp_rect(@cursor_rect, focused_button.outer_rect, 1.0)
    end

    # only process input if the scene is active
    if accepts_input?
      # process inputs based on the last active input device (mouse or keyboard)
      if inputs.last_active == :mouse
        input_mouse
      else
        input_keyboard_controller
      end
    end

    # update the cursor position to be on the focused button (this
    # creates a smooth transition effect when navigating between
    # buttons)
    @cursor_rect = Geometry.lerp_rect(@cursor_rect, focused_button.outer_rect, 0.5)

    # update the button fx queue (this creates the expanding border
    # effect when selecting a button)
    @button_fx_queue.each do |button_fx|
      # to create the effect, we set alpha speed and speed for size
      # increase, and then we update the button_fx rect and alpha
      # based on those speeds. We also increase the speed values to
      # create an accelerating effect as the border expands
      button_fx.da ||= 5
      button_fx.dw ||= 1
      button_fx.dh ||= 1
      button_fx.a  ||= 255

      # update the button_fx rect and alpha based on the speed values
      button_fx.w += button_fx.dw
      button_fx.x -= button_fx.dw / 2
      button_fx.h += button_fx.dh
      button_fx.y -= button_fx.dh / 2
      button_fx.a -= button_fx.da

      # increase the speed values to create an accelerating effect
      button_fx.da += 2
      button_fx.dw += 5
      button_fx.dh += 5
    end

    # we also want to remove any button_fx from the queue once their
    # alpha reaches 0 so that we don't continue processing them
    # unnecessarily
    @button_fx_queue.reject! { |button_fx| button_fx.a <= 0 }
  end

  def input_keyboard_controller
    # first check the navigation mode to determine whether we're
    # navigating level buttons or option buttons, and then check for
    # directional input to navigate between buttons or activation
    # input (enter or controller a button) to select the currently
    # focused button. The rect_navigate function is used to determine
    # which button should be focused based on the directional input
    # and the current focused button.
    if @navigate_mode == :level_buttons
      # if we're in the level button navigation mode, then directional
      # input should navigate between level buttons, and activation
      # input should select the currently focused level and switch to
      # option button navigation mode
      if inputs.key_down.left_right != 0 || inputs.key_down.up_down != 0
        level_button = Geometry.rect_navigate rect: focused_button,
                                              rects: rect_navigate_buttons,
                                              left_right: inputs.key_down.left_right,
                                              up_down: inputs.key_down.up_down,
                                              wrap_x: true,
                                              wrap_y: true,
                                              using:  :rect

        select_level! level_button.level if level_button
      elsif inputs.keyboard.key_down.enter || inputs.controller_one.key_down.a
        # if "accept" is pressed, then we want to select the currently
        # focused level, play the button fx, and switch to option
        # button navigation mode
        focused_button_fx!
        @navigate_mode = :option_buttons
        @selected_option_id = @option_button_prefabs.first.id
      end
    else
      # if we're in the option button navigation mode, then
      # directional input should navigate between option buttons, and
      # activation input should activate the currently focused option
      # button's callback
      if inputs.key_down.left_right != 0 || inputs.key_down.up_down != 0
        option_button = Geometry.rect_navigate rect: focused_button,
                                               rects: rect_navigate_buttons,
                                               left_right: inputs.key_down.left_right,
                                               up_down: inputs.key_down.up_down,
                                               wrap_x: true,
                                               wrap_y: true,
                                               using:  :rect

        select_option! option_button if option_button
      elsif inputs.keyboard.key_down.enter || inputs.controller_one.key_down.a
        focused_button_fx!
        focused_button.callback.call(focused_button)
      end
    end
  end

  def focused_button
    # for keyboard input, this function returns the button that is
    # currently focused (either a level button or an option button
    # depending on the current navigate mode)
    if @navigate_mode == :level_buttons
      @level_button_prefabs.find { |button| button.id == @selected_level_id }
    else
      @option_button_prefabs.find { |button| button.id == @selected_option_id }
    end
  end

  # this represents all the primitives that are avaiable for the scene:
  # - prefabs contain contextual information for a renderable element
  # - by convention, a prefab data structure has a .primitives
  #   attribute which returns one or more primitives
  # - primitives are the raw data structures that get added to args.outputs
  # - the scene has a tick function and then provides a primitives
  #   function that can be called by the root scene and used for rendering
  def primitives
    [
      title_primitive,
      level_buttons_primitives,
      mouse_button_hover_primitive,
      option_primitives,
      cursor_primitives,
      @button_fx_queue
    ]
  end

  def title_primitive
    # returns a label with the correct position based on the
    # oreantation that says "Level Select" at the top of the screen
    rect = if Grid.landscape?
      Layout.allscreen_rect(row: 0, col: 11, w: 2, h: 2)
    else
      Layout.allscreen_rect(row: 1, col: 5, w: 2, h: 1)
    end

    rect.center
        .merge(text: "Level Select",
               **DawnBringer::BRIGHT_WHITE,
               size_px: 56,
               anchor_x: 0.5,
               anchor_y: 0.5)
  end

  def level_buttons_primitives
    # returns the primitives for all the level buttons by mapping over
    # the level_button_prefabs and invoking the
    # level_button_primitives function for each prefab
    @level_button_prefabs.map do |button|
      # the button prefab leverages custom blendmods to create a
      # hollow rectangle for the button border, and it also includes
      # the label text as part of the prefab
      button_prefab(rect: button.rect,
                    text: button.level.abbreviation,
                    color: DawnBringer::BRIGHT_WHITE).primitives
    end
  end

  def mouse_button_hover_primitive
    return nil if inputs.last_active != :mouse

    # find the button that the mouse is currently hovering over by
    # checking for intersection between the mouse rect and the button
    # rects for both level buttons and option buttons. We check level
    # buttons first since they are prioritized when hovering with the
    # mouse
    hovered_button = @level_button_prefabs.find do |button|
      Geometry.intersect_rect? inputs.mouse.rect_allscreen_offset, button.rect
    end

    hovered_button ||= @option_button_prefabs.reject { |button| button.keyboard_only }
                                      .find do |button|
                                        Geometry.intersect_rect? inputs.mouse.rect_allscreen_offset, button.rect
                                      end

    if hovered_button
      # return a primitive that is a cyan rectangle behind the hovered
      # button to indicate that it's being hovered over with the mouse
      return { **hovered_button.rect,
               **DawnBringer::CYAN,
               a: 128,
               path: :solid }
    else
      return nil
    end
  end

  def option_primitives
    # returns primitives for the currently selected level and options
    # (speed and difficulty)
    [
      level_name_primitive,
      option_buttons_primitives
    ]
  end

  def option_buttons_primitives
    # only return option buttons that are interactable with the
    # current input device (for example, if the last active input is
    # mouse, then we don't want to return option buttons that are
    # keyboard only since they can't be interacted with using the
    # mouse)
    buttons = if inputs.last_active == :mouse
                @option_button_prefabs.reject do |option_button|
                  option_button.keyboard_only
                end
              else
                @option_button_prefabs
              end

    buttons.map do |button|
      button_prefab(rect: button.rect,
                    color: DawnBringer::BRIGHT_WHITE,
                    text: button.value.to_s.capitalize,
                    w: button.rect.w,
                    h: button.rect.h).primitives
    end
  end

  def level_name_primitive
    return if !@selected_level
    rect = if Grid.landscape?
             Layout.allscreen_rect(row: 3, col: 17, w: 2, h: 2)
           else
             Layout.allscreen_rect(row: 17, col: 5, w: 2, h: 2)
           end

    rect.center
        .merge(text: @selected_level.name,
               **DawnBringer::BRIGHT_WHITE,
               size_px: 64,
               anchor_x: 0.5,
               anchor_y: 0.5)
  end

  def select_level! level
    return if @selected_level_id == level.id
    @selected_level_id = level.id
    @selected_level = level
    @selected_level_at = Kernel.tick_count
  end

  def select_option! option_button
    return if @selected_option_id == option_button.id
    @selected_option_id = option_button.id
  end

  def rect_navigate_buttons
    if @navigate_mode == :level_buttons
      @level_button_prefabs
    else
      @option_button_prefabs
    end
  end

  def input_mouse
    # return early if the left mouse button isn't released, this prevents
    return if !inputs.mouse.key_up.left

    # check if the mouse is hovering over a level button, and if so,
    # select that level and play the button fx
    level_button = @level_button_prefabs.find do |button|
      Geometry.intersect_rect? inputs.mouse.rect_allscreen_offset, button.rect
    end

    if level_button
      # if the mouse is hovering over a level button, then we want to
      # select
      select_level! level_button.level
      focused_button_fx!
    else
      # if the mouse isn't hovering over a level button, then we check
      # if it's hovering over an option button (that isn't keyboard
      # only), and if so, we want to activate that button's callback
      # function and play the button fx
      option_button = @option_button_prefabs.reject { |button| button.keyboard_only }
                                            .find do |button|
                                              Geometry.intersect_rect? inputs.mouse.rect_allscreen_offset, button.rect
                                            end

      if option_button
        # if the mouse is hovering over an option button, then we want
        # to activate that button's callback function and play the
        # button fx
        option_button.callback.call(option_button)
        @navigate_mode = :option_buttons
        @selected_option_id = option_button.id
        focused_button_fx!
      end
    end
  end

  def focused_button_fx!
    # helper function that adds a button fx to the button_fx_queue for
    # the currently focused button, which creates an expanding border
    # effect when a button is selected
    @button_fx_queue << button_prefab(rect: focused_button.outer_rect,
                                      color: DawnBringer::CYAN,
                                      thickness: 16,
                                      w: focused_button.outer_rect.w,
                                      h: focused_button.outer_rect.h).border_primitive
  end

  def cursor_primitives
    button_prefab(rect: @cursor_rect,
                  color: DawnBringer::CYAN,
                  thickness: 16,
                  w: focused_button.outer_rect.w,
                  h: focused_button.outer_rect.h).primitives
  end

  def button_prefab(rect:, text: "", color:, thickness: 8, w: 100, h: 100)
    # this function generates the primitives for a button prefab,
    # which is a hollow rectangle with text in the middle. To create
    # the hollow rectangle effect, we use custom blendmodes to "punch
    # a hole" in the middle of a solid rectangle. We also generate a
    # border_primitive which is used for the expanding border effect
    # when selecting buttons.

    # see sample app samples/07_advanced_rendering/20_rings
    HOLE_PUNCH_BLENDMODE ||= Numeric.compose_blendmode(BLENDFACTOR_ZERO,
                                                       BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
                                                       BLENDOPERATION_ADD,
                                                       BLENDFACTOR_ZERO,
                                                       BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
                                                       BLENDOPERATION_ADD)
    rt_name = "ring_button_#{w}_#{h}_#{thickness}"

    # create a render target that represents the button border if one
    # hasn't already been queued up for creation
    if !outputs.render_targets.queued? rt_name
      outputs[rt_name].set background_color: [0, 0, 0, 0],
                           w: w,
                           h: h

      outputs[rt_name].primitives << { x: w / 2, y: h / 2, w: w, h: h,
                                       path: :solid, anchor_x: 0.5, anchor_y: 0.5 }
      outputs[rt_name].primitives << { x: w / 2, y: h / 2, w: w - thickness, h: h - thickness,
                                       path: :solid, anchor_x: 0.5, anchor_y: 0.5 }
      outputs[rt_name].primitives << { x: w / 2, y: h / 2, w: w - thickness, h: h - thickness,
                                       path: :solid, anchor_x: 0.5, anchor_y: 0.5, blendmode: HOLE_PUNCH_BLENDMODE }
    end

    # if we are still in the process of creating the render target, we
    # want to return an empty prefab until it's ready
    return { primitives: nil } if !outputs.render_targets.ready? rt_name

    border_primitive = {
      x: rect.x,
      y: rect.y,
      w: rect.w,
      h: rect.h,
      path: rt_name,
      r: color.r,
      g: color.g,
      b: color.b
    }

    # return the prefab data structure
    {
      border_primitive: border_primitive,
      primitives: [
        border_primitive,
        {
          x: rect.x + rect.w / 2,
          y: rect.y + rect.h / 2,
          text: text,
          **DawnBringer::BRIGHT_WHITE,
          size_px: 32,
          anchor_x: 0.5,
          anchor_y: 0.5
        }
      ]
    }
  end
end

# the game scene has the same general flow as the level select scene
# just a place holder for where the game would so up
class LevelScene < Scene
  def id = :game

  def activate!
    @level = state.level_selection.level
    @speed = state.level_selection.speed
    @difficulty = state.level_selection.difficulty
  end

  def tick
    if accepts_input?
      if inputs.mouse.click || inputs.keyboard.key_down.enter || inputs.controller_one.key_down.a
        state.next_scene = :level_select
      end
    end
  end

  def primitives
    return [] if !@level

    [
      {
        x: Grid.allscreen_w / 2, y: Grid.allscreen_h / 2,
        text: "Game Scene",
        anchor_x: 0.5, anchor_y: -1.5, size_px: 32,
        **DawnBringer::BRIGHT_WHITE,
      },
      {
        x: Grid.allscreen_w / 2, y: Grid.allscreen_h / 2,
        text: "Level: #{@level.name}",
        anchor_x: 0.5, anchor_y: -0.5, size_px: 32,
        **DawnBringer::BRIGHT_WHITE,
      },
      {
        x: Grid.allscreen_w / 2, y: Grid.allscreen_h / 2,
        text: "Speed: #{@speed}",
        anchor_x: 0.5, anchor_y: 0.5, size_px: 32,
        **DawnBringer::BRIGHT_WHITE,
      },
      {
        x: Grid.allscreen_w / 2, y: Grid.allscreen_h / 2,
        text: "Difficulty: #{@difficulty}",
        anchor_x: 0.5, anchor_y: 1.5, size_px: 32,
        **DawnBringer::BRIGHT_WHITE,
      },
      {
        x: Grid.allscreen_w / 2, y: Grid.allscreen_h / 2,
        text: instruction_text,
        anchor_x: 0.5, anchor_y: 2.5, size_px: 32,
        **DawnBringer::BRIGHT_WHITE,
      },
    ]
  end

  def instruction_text
    if inputs.last_active == :mouse
      "Instructions: Click to go back"
    elsif inputs.last_active == :keyboard
      "Instructions: Press Enter to go back"
    else
      "Instructions: Press X on your controller to go back"
    end
  end
end

module DawnBringer
  BLACK = { r: 20, g: 12, b: 28 }
  BLUE = { r: 89, g: 125, b: 206 }
  BLUE_GRAY = { r: 155, g: 173, b: 183 }
  BRIGHT_CYAN = { r: 95, g: 205, b: 228 }
  BRIGHT_GREEN = { r: 153, g: 229, b: 80 }
  BRIGHT_ORANGE = { r: 223, g: 113, b: 38 }
  BRIGHT_PURPLE = { r: 91, g: 110, b: 225 }
  BRIGHT_WHITE = { r: 232, g: 232, b: 232 }
  BRIGHT_YELLOW = { r: 251, g: 242, b: 54 }
  BROWN = { r: 133, g: 76, b: 48 }
  CHARCOAL = { r: 105, g: 106, b: 106 }
  CYAN = { r: 109, g: 194, b: 202 }
  DARK_BLUE = { r: 48, g: 52, b: 109 }
  DARK_BROWN_GRAY = { r: 89, g: 86, b: 82 }
  DARK_GRAY = { r: 78, g: 74, b: 78 }
  DARK_GREEN = { r: 52, g: 101, b: 36 }
  DARK_MAGENTA = { r: 69, g: 40, b: 60 }
  DARK_OLIVE = { r: 82, g: 75, b: 36 }
  DARK_PURPLE = { r: 68, g: 36, b: 52 }
  DARK_PURPLE_BLUE = { r: 34, g: 32, b: 52 }
  DARK_RED = { r: 172, g: 50, b: 50 }
  DARK_RED_BROWN = { r: 102, g: 57, b: 49 }
  DARK_TEAL = { r: 50, g: 60, b: 57 }
  GOLD = { r: 138, g: 111, b: 48 }
  GRAY = { r: 117, g: 113, b: 97 }
  GREEN = { r: 109, g: 170, b: 44 }
  LIGHT_BLUE = { r: 203, g: 219, b: 252 }
  LIGHT_GRAY = { r: 133, g: 149, b: 161 }
  LIGHT_GREEN_GRAY = { r: 196, g: 207, b: 161 }
  LIGHT_PEACH = { r: 238, g: 195, b: 154 }
  LIGHT_TAN = { r: 217, g: 160, b: 102 }
  MEDIUM_BROWN = { r: 143, g: 86, b: 59 }
  MEDIUM_GRAY = { r: 132, g: 126, b: 135 }
  MEDIUM_GREEN = { r: 106, g: 190, b: 48 }
  MEDIUM_PURPLE = { r: 63, g: 63, b: 116 }
  OLIVE_GREEN = { r: 75, g: 105, b: 47 }
  ORANGE = { r: 210, g: 125, b: 44 }
  PURE_BLACK = { r: 0, g: 0, b: 0 }
  PURE_WHITE = { r: 255, g: 255, b: 255 }
  PURPLE = { r: 118, g: 66, b: 138 }
  RED = { r: 208, g: 70, b: 72 }
  SKY_BLUE = { r: 99, g: 155, b: 255 }
  STEEL_BLUE = { r: 48, g: 96, b: 130 }
  TAN = { r: 210, g: 170, b: 153 }
  TEAL = { r: 55, g: 148, b: 110 }
  WHITE = { r: 222, g: 238, b: 214 }
  YELLOW = { r: 218, g: 212, b: 94 }
end

DR.reset
