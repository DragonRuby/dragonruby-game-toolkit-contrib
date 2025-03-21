# sample app shows how you can user a queue/callback mechanism to create cutscenes
class Game
  attr_gtk

  def initialize
    # this class controls the cutscene orchestration
    @tick_queue = TickQueue.new
  end

  def tick
    @tick_queue.args = args
    state.player ||= { x: 0, y: 0, w: 100, h: 100, path: :pixel, r: 0, g: 255, b: 0 }
    state.fade_to_black ||= 0
    state.back_and_forth_count ||= 0

    # if the mouse is clicked, start the cutscene
    if inputs.mouse.click && !state.cutscene_started
      start_cutscene
    end

    outputs.primitives << state.player
    outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :pixel, r: 0, g: 0, b: 0, a: state.fade_to_black }
    @tick_queue.tick
  end

  def start_cutscene
    # don't start the cutscene if it's already started
    return if state.cutscene_started
    state.cutscene_started = true

    # start the cutscene by moving right
    queue_move_to_right_side
  end

  def queue_move_to_right_side
    # use the tick queue mechanism to kick off the player moving right
    @tick_queue.queue_tick Kernel.tick_count do |args, entry|
      state.player.x += 30
      # once the player is done moving right, stage the next step of the cutscene (moving left)
      if state.player.x + state.player.w > 1280
        state.player.x = 1280 - state.player.w
        queue_move_to_left_side

        # marke the queued tick entry as complete so it doesn't get run again
        entry.complete!
      end
    end
  end

  def queue_move_to_left_side
    # use the tick queue mechanism to kick off the player moving right
    @tick_queue.queue_tick Kernel.tick_count do |args, entry|
      args.state.player.x -= 30
      # once the player id done moving left, decide on whether they should move right again or fade to black
      # the decision point is based on the number of times the player has moved left and right
      if args.state.player.x < 0
        state.player.x = 0
        args.state.back_and_forth_count += 1
        if args.state.back_and_forth_count < 3
          # if they haven't moved left and right 3 times, move them right again
          queue_move_to_right_side
        else
          # if they have moved left and right 3 times, fade to black
          queue_fade_to_black
        end

        # marke the queued tick entry as complete so it doesn't get run again
        entry.complete!
      end
    end
  end

  def queue_fade_to_black
    # we know the cutscene will end in 255 tickes, so we can queue a notification that will kick off in the future notifying that the cutscene is done
    @tick_queue.queue_one_time_tick Kernel.tick_count + 255 do |args, entry|
      GTK.notify "Cutscene complete!"
    end

    # start the fade to black
    @tick_queue.queue_tick Kernel.tick_count do |args, entry|
      args.state.fade_to_black += 1
      entry.complete! if state.fade_to_black > 255
    end
  end
end

# this construct handles the execution of animations/cutscenes
# the key methods that are used are queue_tick and queue_one_time_tick
class TickQueue
  attr_gtk

  attr :queued_ticks
  attr :queued_ticks_currently_running

  def initialize
    @queued_ticks ||= {}
    @queued_ticks_currently_running ||= []
  end

  # adds a callback that will be processed
  def queue_tick at, &block
    @queued_ticks[at] ||= []
    @queued_ticks[at] << QueuedTick.new(at, &block)
  end

  # adds a callback that will be processed and immediately marked as complete
  def queue_one_time_tick at, **metadata, &block
    @queued_ticks ||= {}
    @queued_ticks[at] ||= []
    @queued_ticks[at] << QueuedOneTimeTick.new(at, &block)
  end

  def tick
    # get all queued callbacs that need to start running on the current frame
    entries_this_tick = @queued_ticks.delete Kernel.tick_count

    # if there are values, then add them to the list of currently running callbacks
    if entries_this_tick
      @queued_ticks_currently_running.concat entries_this_tick
    end

    # run tick on each entry
    @queued_ticks_currently_running.each do |queued_tick|
      queued_tick.tick args
    end

    # remove all entries that are complete
    @queued_ticks_currently_running.reject!(&:complete?)

    # there is a chance that a queued tick will queue another tick, so we need to check
    # if there are any queued ticks for the current frame. if so, then recursively call tick again
    if @queued_ticks[Kernel.tick_count] && @queued_ticks[Kernel.tick_count].length > 0
      tick
    end
  end
end

# small data structure that holds the callback and status
# queue_tick constructs an instance of this class to faciltate
# the execution of the block and it's completion
class QueuedTick
  attr :queued_at, :block

  def initialize queued_at, &block
    @queued_at = queued_at
    @is_complete = false
    @block = block
  end

  def complete!
    @is_complete = true
  end

  def complete?
    @is_complete
  end

  def tick args
    @block.call args, self
  end
end

# small data structure that holds the callback and status
# queue_one_time_tick constructs an instance of this class to faciltate
# the execution of the block and it's completion
class QueuedOneTimeTick < QueuedTick
  def tick args
    @block.call args, self
    @is_complete = true
  end
end


$game = Game.new
def tick args
  $game.args = args
  $game.tick
end

GTK.reset
