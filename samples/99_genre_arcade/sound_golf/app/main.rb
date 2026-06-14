# class that encapsulates all game logic and state
class Game
  # attr_dr is a helper class macro that adds `args` attribuets to the class so you don't have to pass `args` around to every method
  attr_dr

  # this is the constructor
  def initialize
    # list of available notes
    @available_notes = [:C3, :D3, :E3, :F3, :G3, :A3, :B3, :C4]

    # queue of click effects to render
    @click_fx_queue = []

    # location of play again and play note buttons
    @play_again_button = Layout.rect(row: 2, col: 10, w: 4, h: 2)
    @play_note_button = Layout.rect(row: 2, col: 10, w: 4, h: 2)

    # location of guess note buttons, generated based on available notes
    @guess_note_buttons = @available_notes.map_with_index do |note, index|
      Layout.rect(row: 6, col: 4 + index * 2, w: 2, h: 2).merge(note: note)
    end

    # start a new game
    new_game!
  end

  def new_game!
    # current level is set to 1 and time stamp is captured so that items can fade in based on how long the player has been on the current level
    @current_level = 1
    @current_level_at = Kernel.tick_count

    # pre-generate the solutions for each level
    @level_notes = {}
    9.times do |i|
      # exclude notes that have been recently played in the previous 2 levels
      previous_level_notes = [@level_notes[i], @level_notes[i - 1]].compact

      # take a random note from the available notes that isn't in the previous level notes and assign it to the current level
      @level_notes[i + 1] = @available_notes.reject do |note|
        previous_level_notes.include?(note)
      end.sample
    end

    # keeps track of how many times the player has guessed wrong for scoring purposes
    @times_wrong = 0

    # markes the game as over so that they get the option to play again
    @game_over = false
  end

  def tick
    calc
    render
  end

  def calc
    # process the click fx queue by lerping the width, height, and alpha of each
    # effect towards their final values and removing them from the queue once they are fully faded out
    @click_fx_queue.each do |fx|
      fx.w_final ||= fx.w * 2
      fx.h_final ||= fx.h * 2
      fx.w = fx.w.lerp(fx.w_final, 0.2, tolerance: 1)
      fx.h = fx.h.lerp(fx.h_final, 0.2, tolerance: 1)
      fx.a = fx.a.lerp(0, 0.2, tolerance: 1)
    end

    @click_fx_queue.reject! { |fx| fx.a <= 0 }

    # automatically play the current level note after 60 frames (1 second)
    if @current_level_at.elapsed_time == 60
      play_current_level_note!
    end

    # if the mouse is clicked...
    if inputs.mouse.click
      # if the game is over, check if they clicked the play again button
      if @game_over
        if Geometry.intersect_rect?(inputs.mouse.rect, @play_again_button)
          queue_click_fx!(rect: @play_again_button, r: 0, g: 160, b: 160)
          new_game!
        end
      else
        # if the game isn't over, check if they clicked the play note button or one of the guess note buttons
        if Geometry.intersect_rect?(inputs.mouse.rect, @play_note_button)
          play_current_level_note!
        else
          # see if they clicked any of the guess note buttons by finding the first button that intersects with the mouse click
          clicked_button = @guess_note_buttons.find do |button|
            Geometry.intersect_rect?(inputs.mouse.rect, button)
          end

          check_guess clicked_button
        end
      end
    end
  end

  def play_current_level_note!
    queue_click_fx!(rect: @play_note_button, r: 0, g: 160, b: 160)
    outputs.sounds << "sounds/#{@level_notes[@current_level].to_s.downcase}.ogg"
  end

  # check guess function compares the note they clicked to the note of the current level
  def check_guess button
    # ignore if they button is nil
    return if !button

    # if the button's note matches the level's note...
    if button.note == @level_notes[@current_level]
      queue_click_fx!(rect: button, r: 0, g: 160, b: 0)

      # mark the game as over if it's the last level
      if @current_level == 9
        @game_over = true
      else
        # otherwise, move on to the next level by incrementing the current level and capturing a new time stamp for the fade in effect
        @current_level += 1
        @current_level_at = Kernel.tick_count
      end
    else
      # if they guessed wrong then queue a red click effect and increment the times wrong for scoring purposes
      queue_click_fx!(rect: button, r: 160, g: 0, b: 0)
      @times_wrong += 1
    end

    # play the note of the button they clicked as feedback for what they clicked on
    outputs.sounds << "sounds/#{button.note.to_s.downcase}.ogg"
  end

  def render
    outputs.background_color = [30, 30, 30]

    # render current hole and current score
    outputs.primitives << hole_prefab
    outputs.primitives << score_prefab

    if @game_over
      # only render the play again button if the game is over
      outputs.primitives << play_again_button_prefab
    else
      # otherwise, render the play note button and the guess note buttons
      outputs.primitives << play_note_button_prefab
      outputs.primitives << instructions_prefab
      outputs.primitives << @guess_note_buttons.map { |button| button_prefab(button, button.note.to_s) }
    end

    # render click effects
    outputs.primitives << @click_fx_queue

    # this helper method was used to position controls
    # outputs.debug << Layout.debug_primitives(invert_colors: true, a: 128)
  end

  def queue_click_fx!(rect:, r:, g:, b:)
    # function for adding a click effect
    center = Geometry.center rect
    @click_fx_queue << { x: center.x,
                         y: center.y,
                         w: rect.w,
                         h: rect.h,
                         r: r,
                         g: g,
                         b: b,
                         a: 255,
                         anchor_x: 0.5,
                         anchor_y: 0.5,
                         path: :solid }
  end

  def hole_prefab
    # label representing the current level
    Layout.rect(row: 0, col: 11, w: 2, h: 1)
          .center
          .merge text: "Hole #{@current_level} of 9",
                 anchor_x: 0.5,
                 anchor_y: 0.5,
                 r: 255,
                 g: 255,
                 b: 255,
                 a: round_fade_in_alpha,
                 size_px: 32
  end

  def score_prefab
    # label representing the current score
    text = if @times_wrong == 0
             "Score: PAR"
           else
             "Score: +#{@times_wrong}"
           end

    Layout.rect(row: 0, col: 11, w: 2, h: 1)
          .center
          .merge(text: text,
                 anchor_x: 0.5,
                 anchor_y: 0.5,
                 anchor_y: 2.0,
                 size_px: 32,
                 a: round_fade_in_alpha,
                 r: 255,
                 g: 255,
                 b: 255)
  end

  def instructions_prefab
    # label providing instructions
    Layout.rect(row: 3, col: 11, w: 2, h: 2)
          .center
          .merge(text: "Click one of the notes below to guess the note being played",
                 anchor_x: 0.5,
                 anchor_y: 0.5,
                 anchor_y: 2.0,
                 size_px: 32,
                 a: round_fade_in_alpha,
                 r: 255,
                 g: 255,
                 b: 255)
  end

  def play_again_button_prefab
    button_prefab(@play_again_button, "Play Again")
  end

  def play_note_button_prefab
    button_prefab(@play_note_button, "Play Note")
  end

  def round_fade_in_alpha
    (@current_level_at.elapsed_time.fdiv(30) ** 2) * 255
  end

  def button_prefab rect, text
    # the button prefab is a composition of a solid rectangle with the text centered within the rect.
    [
      rect.merge(path: :solid,
                 r: 0,
                 g: 60,
                 b: 60,
                 a: 255),
      rect.center.merge(text: text,
                        anchor_x: 0.5,
                        anchor_y: 0.5,
                        a: 255,
                        r: 255,
                        g: 255,
                        b: 255,
                        size_px: 32)
    ]
  end
end

def boot args
  args.state = {}
end

def tick args
  # entry point of the game
  $game ||= Game.new
  $game.args = args
  $game.tick
end

def reset args
  # set the game to nil if DR.reset is invoked so that it gets re-initialized on the next tick
  $game = nil
end

DR.reset
