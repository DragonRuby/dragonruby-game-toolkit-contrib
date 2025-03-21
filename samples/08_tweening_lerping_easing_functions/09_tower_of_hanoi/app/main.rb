class Game
  attr_gtk

  # get solution for hanoi tower
  # https://youtu.be/rf6uf3jNjbo
  def solve count, from, to, other
    solve_recur(count, from, to, other).flatten
  end

  # recursive function for getting solution
  def solve_recur count, from, to, other
    if count == 1
      [{ from: from, to: to }]
    else
      [
        solve(count - 1, from, other, to),
        { from: from, to: to },
        solve(count - 1, other, to, from)
      ]
    end
  end

  def post_message message
    return if state.message_at && state.message == message && state.message_at.elapsed_time < 180
    state.message = message
    state.message_at = Kernel.tick_count
  end

  # initialize default values
  def defaults
    # number of discs for tower
    state.disc_count ||= 4
    # queue for peg selection (items in queue are processed after animations complete)
    state.select_peg_queue ||= []

    # precompute button locations based off of a 24x12 grid
    state.undo_button_rect ||= Layout.rect(row: 11, col: 8, w: 4, h: 1)
    state.auto_solve_button_rect ||= Layout.rect(row: 11, col: 12, w: 4, h: 1)
    state.select_peg_1_button_rect ||= Layout.rect(row: 10, col: 1.5, w: 5, h: 1)
    state.select_peg_2_button_rect ||= Layout.rect(row: 10, col: 9.5, w: 5, h: 1)
    state.select_peg_3_button_rect ||= Layout.rect(row: 10, col: 17.5, w: 5, h: 1)

    # default duration for disc animations
    state.animation_duration ||= 15

    # history of moves (used for undoing and resetting game)
    state.move_history ||= []

    if !state.tower
      # generate discs
      discs = state.disc_count.map do |i|
        { sz: i + 1 }
      end

      # create pegs
      state.tower = {
        pegs: [
          { index: 0, discs: discs.reverse },
          { index: 1, discs: [] },
          { index: 2, discs: [] },
        ]
      }

      # calculate peg render and click locations
      state.tower.pegs.each do |peg|
        x = Layout.rect(row: 0, col: peg.index * 8, w: 8, h: 1).center.x
        y, h = Layout.rect(row: 2, col: 0, w: 1, h: 8).slice(:y, :h).values
        peg.render_box = {
          x: x,
          y: y,
          w: 32,
          h: h,
          anchor_x: 0.5,
        }

        peg.hit_box = {
          x: x,
          y: y,
          w: 256,
          h: h,
          anchor_x: 0.5,
        }
      end

      # associate buttons to pegs
      state.tower.pegs[0].button_rect = state.select_peg_1_button_rect
      state.tower.pegs[1].button_rect = state.select_peg_2_button_rect
      state.tower.pegs[2].button_rect = state.select_peg_3_button_rect
    end

    # compute hanoi solution
    state.solution ||= solve(state.disc_count, 0, 2, 1)
  end

  # queue peg selection
  def queue_select_peg(peg, add_history:, animation_duration:)
    state.select_peg_queue.push_back peg: peg,
                                     add_history: add_history,
                                     animation_duration: animation_duration
  end

  # select peg action
  def select_peg(peg, add_history:, animation_duration:)
    # return if peg is nil
    return if !peg

    if !state.from_peg && peg.discs.any?
      # if from_peg is not set and the peg that is being selected has discs
      # set the from_peg
      state.from_peg = peg
      # generate a disc event (used for animations)
      state.disc_event = {
        type: :take,
        from_peg: peg,
        to_peg: peg,
        at: Kernel.tick_count,
        disc: peg.discs.last,
        duration: animation_duration
      }

      # reset the destination peg
      state.to_peg = nil

      # record move history if option is true
      # (when undoing moves, we don't want to record history)
      state.move_history << peg.index if add_history
    elsif state.from_peg == peg
      # if the destination peg is the same as the start peg
      # create an animation event that is half way done so
      # that only the drop disc part of the animation is performed
      state.to_peg = peg
      state.disc_event = {
        type: :drop,
        from_peg: peg,
        to_peg: peg,
        disc: state.from_peg.discs.last,
        at: Kernel.tick_count - animation_duration,
        duration: animation_duration * 2
      }
      # set from peg to nil
      state.from_peg = nil
      # record move history
      state.move_history << peg.index if add_history
    elsif state.from_peg
      # if the start and destination pegs are different
      # check to see if the destination location is valid
      # (top disc must be larger than disc being placed)
      state.to_peg = peg
      disc = state.from_peg.discs.pop_back
      valid_move = !state.to_peg.discs.last || (state.to_peg.discs.last.sz > disc.sz)

      if valid_move
        # if it's valid, then pop the disc from the source
        # and place it at the destination
        state.to_peg.discs.push_back disc
        # create a drop event to animate disc
        state.disc_event = {
          type: :drop,
          from_peg: state.from_peg,
          to_peg: state.to_peg,
          disc: disc,
          at: Kernel.tick_count,
          duration: animation_duration * 2
        }
        # record move history
        state.move_history << peg.index if add_history
      else
        post_message "Invalid Move..."
        # if it's invalid, place the disc back onto its source peg
        state.from_peg.discs.push_back disc
        # create drop event to animate disc
        state.disc_event = {
          type: :drop,
          from_peg: state.from_peg,
          to_peg: state.from_peg,
          disc: disc,
          at: Kernel.tick_count,
          duration: animation_duration * 2
        }

        # remove the entry in history
        state.move_history.pop_back
      end

      # clear the origination peg
      state.from_peg = nil
    end
  end

  def calc_disc_positions
    # every frame, calculate the render location of discs
    state.tower.pegs.each do |peg|
      # for each peg
      peg.discs.each_with_index do |disc, i|
        # for each disc calculate the default x and y position for rendering
        default_x = peg.render_box.x
        default_y = peg.render_box.y + i * 32
        removed_from_peg_y = Layout.rect(row: 1, col: 0, w: 1, h: 1).center.y - 16

        if state.disc_event && state.disc_event.disc == disc && state.disc_event.type == :take
          # if there is a "take" disc event and the target is the disc currently being processed
          # compute the easing function and update x, y accordingly
          from_peg_x = state.disc_event.from_peg.render_box.x
          to_peg_x = state.disc_event.to_peg.render_box.x

          perc = Easing.smooth_start(start_at: state.disc_event.at,
                                     end_at: state.disc_event.at + state.disc_event.duration,
                                     tick_count: Kernel.tick_count,
                                     power: 2)

          x = from_peg_x.lerp(to_peg_x, perc)
          y = default_y.lerp(removed_from_peg_y, perc)
        elsif state.disc_event && state.disc_event.disc == disc && state.disc_event.type == :drop
          # if there is a "drop" disc event and the target is the disc currently being processed
          # compute the easing function and update x, y accordingly
          from_peg_x = state.disc_event.from_peg.render_box.x
          to_peg_x = state.disc_event.to_peg.render_box.x

          # first part of the animation is the movement to the new peg
          perc = Easing.smooth_start(start_at: state.disc_event.at,
                                     end_at: state.disc_event.at + state.disc_event.duration / 2,
                                     tick_count: Kernel.tick_count,
                                     power: 2)

          x = from_peg_x.lerp(to_peg_x, perc)

          # second part of the animation is the drop of the peg at the new location
          perc = Easing.smooth_start(start_at: state.disc_event.at + state.disc_event.duration / 2,
                                     end_at: state.disc_event.at + state.disc_event.duration,
                                     tick_count: Kernel.tick_count,
                                     power: 2)

          y = removed_from_peg_y.lerp(default_y, perc)
        else
          # if there is no disc event, then set the x and y value to the defaults
          # for the disc
          x = default_x
          y = default_y
        end

        # width of the disc is the width of the peg multiplied by its size
        w = peg.render_box.w + disc.sz * 32

        # set the disc's render box
        disc.render_box = {
          x: x,
          y: y,
          w: w,
          h: 32,
          anchor_x: 0.5
        }
      end
    end
  end

  def rollback_all_moves
    # based on the number of moves in the move history
    # slowly increase the animation speed during rollback
    move_count = state.move_history.length
    state.move_history.reverse.each_with_index do |entry, index|
      percentage_complete = (index + 1).fdiv move_count
      animation_duration = (state.animation_duration - state.animation_duration * percentage_complete).clamp(4, state.animation_duration)
      peg_index = state.move_history.pop_back
      peg = state.tower.pegs[peg_index]
      queue_select_peg peg, add_history: false, animation_duration: animation_duration.to_i
    end
  end

  def calc_auto_solve
    # return if already auto solving or if the game is completed
    return if state.auto_solving
    return if state.completed_at

    auto_solve_requested   = inputs.mouse.up && inputs.mouse.intersect_rect?(state.auto_solve_button_rect)
    auto_solve_requested ||= inputs.keyboard.key_down.space

    # if space is pressed, do an auto solve of the game
    if auto_solve_requested
      post_message "Auto Solving..."
      state.auto_solving = true
      # rollback all moves before starting the auto solve
      rollback_all_moves
      # based on the number of moves to complete the tower
      # slowly increase the animation speed
      move_count = 2**state.disc_count - 1
      state.solution.each_with_index do |move, index|
        percentage_complete = (index + 1).fdiv move_count
        animation_duration = (state.animation_duration - state.animation_duration * percentage_complete).clamp(4, state.animation_duration)
        queue_select_peg state.tower.pegs[move[:from]], add_history: true, animation_duration: animation_duration.to_i
        queue_select_peg state.tower.pegs[move[:to]], add_history: true, animation_duration: animation_duration.to_i
      end
    end
  end

  def calc_game_ended
    # game is completed if all discs are on the last peg
    all_discs_on_last_peg = state.tower.pegs[0].discs.length == 0 && state.tower.pegs[1].discs.length == 0
    if all_discs_on_last_peg
      state.completed_at ||= Kernel.tick_count
      state.started_at = nil
    end

    if state.completed_at == Kernel.tick_count
      post_message "Complete..."
    end

    # if the game is completed roll back everything so they can play again
    if state.completed_at && state.completed_at.elapsed_time > 60
      rollback_all_moves
    end

    # game is at the start if all discs are on the first peg
    all_discs_on_first_peg = state.tower.pegs[1].discs.length == 0 && state.tower.pegs[2].discs.length == 0
    if all_discs_on_first_peg
      state.completed_at = nil
      state.started_at ||= Kernel.tick_count
    end

    if state.started_at == Kernel.tick_count
      post_message "Ready..."
    end

    # if the game is at the start and there are no moves in
    # the move history or in the select peg queue,
    # then set auto solving to false
    if all_discs_on_first_peg && state.move_history.length == 0 && state.select_peg_queue.length == 0
      state.auto_solving = false
    end
  end

  def calc_input
    return if state.auto_solving
    return if state.completed_at

    # process user input either mouse or keyboard
    state.hovered_peg = state.tower.pegs.find { |peg| inputs.mouse.intersect_rect?(peg.hit_box) || inputs.mouse.intersect_rect?(peg.button_rect) }

    undo_requested   = inputs.mouse.up && inputs.mouse.intersect_rect?(state.undo_button_rect)
    undo_requested ||= inputs.keyboard.key_down.u
    undo_requested   = false if state.move_history.length == 0

    # keyboard j, k, l to select pegs, u to undo
    if inputs.keyboard.key_down.j
      queue_select_peg state.tower.pegs[0], add_history: true, animation_duration: state.animation_duration
    elsif inputs.keyboard.key_down.k
      queue_select_peg state.tower.pegs[1], add_history: true, animation_duration: state.animation_duration
    elsif inputs.keyboard.key_down.l
      queue_select_peg state.tower.pegs[2], add_history: true, animation_duration: state.animation_duration
    elsif undo_requested
      post_message "Undo..."
      if state.move_history.length.even?
        peg_index = state.move_history.pop_back
        peg = state.tower.pegs[peg_index]
        queue_select_peg peg, add_history: false, animation_duration: state.animation_duration

        peg_index = state.move_history.pop_back
        peg = state.tower.pegs[peg_index]
        queue_select_peg peg, add_history: false, animation_duration: state.animation_duration
      else
        peg_index = state.move_history.pop_back
        peg = state.tower.pegs[peg_index]
        queue_select_peg peg, add_history: false, animation_duration: state.animation_duration
      end
    end

    # peg selection using mouse
    if state.hovered_peg && inputs.mouse.up
      queue_select_peg state.hovered_peg, add_history: true, animation_duration: state.animation_duration
    end
  end

  def calc_peg_queue
    # don't process selection queue if there are animation events pending
    disc_event_elapsed = if !state.disc_event
                           true
                         else
                           state.disc_event.at.elapsed_time > state.disc_event.duration
                         end


    # if there are no animation events then process the first item from the queue
    if disc_event_elapsed && state.select_peg_queue.length > 0
      entry = state.select_peg_queue.pop_front
      select_peg entry.peg, add_history: entry.add_history, animation_duration: entry.animation_duration
    end
  end

  def calc
    calc_disc_positions
    calc_auto_solve
    calc_game_ended
    calc_input
    calc_peg_queue
  end

  def render
    # render background
    outputs.background_color = [30, 30, 30]

    # render message
    if state.message && state.message_at
      duration = 180
      # spline represents an easing function for fading in and out
      # of the message
      spline_definition = [
        [0.00, 0.00, 0.66, 1.00],
        [1.00, 1.00, 1.00, 1.00],
        [1.00, 0.66, 0.00, 0.00]
      ]

      perc = Easing.spline state.message_at,
                           Kernel.tick_count,
                           duration,
                           spline_definition

      outputs.primitives << Layout.rect(row: 0, col: 0, w: 24, h: 1)
                                  .center
                                  .merge(text: state.message,
                                         anchor_x: 0.5,
                                         anchor_y: 0.5,
                                         r: 255, g: 255, b: 255,
                                         anchor_x: 0.5,
                                         anchor_y: 0.5,
                                         size_px: 32,
                                         a: 255 * perc)
    end

    # render pegs
    outputs.primitives << state.tower.pegs.map do |peg|
      peg.render_box.merge(path: :solid, r: 128, g: 128, b: 128)
    end

    # render visual indicators for currently hovered peg
    if state.hovered_peg && inputs.last_active == :mouse
      outputs.primitives << state.hovered_peg.render_box.merge(path: :solid, r: 80, g: 128, b: 80)
    end

    # render visual indicator for selected peg
    if state.from_peg
      outputs.primitives << state.from_peg.render_box.merge(path: :solid, r: 80, g: 80, b: 128)
    end

    # render visual indicator for destination peg
    if state.to_peg
      outputs.primitives << state.to_peg.render_box.merge(path: :solid, r: 0, g: 80, b: 80)
    end

    # render disks
    outputs.primitives << state.tower.pegs.map do |peg|
      peg.discs.map do |disc|
        disc.render_box.merge(path: :solid, r: 200, g: 200, b: 200).scale_rect(0.95)
      end
    end

    # render platform/intput specific controls
    if inputs.last_active == :keyboard
      outputs.primitives << button_prefab(state.select_peg_1_button_rect, "J: Select Peg 1")
      outputs.primitives << button_prefab(state.select_peg_2_button_rect, "K: Select Peg 2")
      outputs.primitives << button_prefab(state.select_peg_3_button_rect, "L: Select Peg 3")
      outputs.primitives << button_prefab(state.undo_button_rect, "U: Undo")
      outputs.primitives << button_prefab(state.auto_solve_button_rect, "Space: Auto Solve")
    else
      action_text = if GTK.platform?(:touch)
                      "Tap"
                    else
                      "Click"
                    end

      outputs.primitives << button_prefab(state.select_peg_1_button_rect, "#{action_text}: Select Peg 1")
      outputs.primitives << button_prefab(state.select_peg_2_button_rect, "#{action_text}: Select Peg 2")
      outputs.primitives << button_prefab(state.select_peg_3_button_rect, "#{action_text}: Select Peg 3")
      outputs.primitives << button_prefab(state.undo_button_rect, "Undo")
      outputs.primitives << button_prefab(state.auto_solve_button_rect, "Auto Solve")
    end
  end

  def button_prefab rect, text
    color = if inputs.mouse.intersect_rect?(rect)
              { r: 255, g: 255, b: 255 }
            else
              { r: 128, g: 128, b: 128 }
            end
    [
      rect.merge(primitive_marker: :border, **color),
      rect.center.merge(text: text, r: 255, g: 255, b: 255, anchor_x: 0.5, anchor_y: 0.5)
    ]
  end

  def tick
    # execution pipeline
    # initialize game defaults, calculate game, render game
    defaults
    calc
    render
  end
end

def boot args
  args.state = { }
end

def tick args
  # entry point
  $game ||= Game.new
  $game.args = args
  $game.tick
end

def reset args
  $game = nil
end

GTK.reset
