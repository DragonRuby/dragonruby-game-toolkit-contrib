class Game
  attr_gtk

  def request_action name, at: nil
    at ||= state.tick_count
    state.player.requested_action = name
    state.player.requested_action_at = at
  end

  def defaults
    state.player.x                  ||= 64
    state.player.y                  ||= 0
    state.player.dx                 ||= 0
    state.player.dy                 ||= 0
    state.player.action             ||= :standing
    state.player.action_at          ||= 0
    state.player.next_action_queue  ||= {}
    state.player.facing             ||= 1
    state.player.jump_at            ||= 0
    state.player.jump_count         ||= 0
    state.player.max_speed          ||= 1.0
    state.sabre.x                   ||= state.player.x
    state.sabre.y                   ||= state.player.y
    state.actions_lookup            ||= new_actions_lookup
  end

  def render
    outputs.background_color = [32, 32, 32]
    outputs[:scene].w = 128
    outputs[:scene].h = 128
    outputs[:scene].borders << { x: 0, y: 0, w: 128, h: 128, r: 255, g: 255, b: 255 }
    render_player
    render_sabre
    args.outputs.sprites << { x: 320, y: 0, w: 640, h: 640, path: :scene }
    args.outputs.labels << { x: 10, y: 100, text: "Controls:", r: 255, g: 255, b: 255, size_enum: -1 }
    args.outputs.labels << { x: 10, y: 80, text: "Move:   left/right", r: 255, g: 255, b: 255, size_enum: -1 }
    args.outputs.labels << { x: 10, y: 60, text: "Jump:   space | up | right click", r: 255, g: 255, b: 255, size_enum: -1 }
    args.outputs.labels << { x: 10, y: 40, text: "Attack: f     | j  | left click", r: 255, g: 255, b: 255, size_enum: -1 }
  end

  def render_sabre
    return if !state.sabre.is_active
    sabre_index = 0.frame_index count:    4,
                                hold_for: 2,
                                repeat:   true
    offset =  0
    offset = -8 if state.player.facing == -1
    outputs[:scene].sprites << { x: state.sabre.x + offset,
                        y: state.sabre.y, w: 16, h: 16, path: "sprites/sabre-throw/#{sabre_index}.png" }
  end

  def new_actions_lookup
    r = {
      slash_0: {
        frame_count: 6,
        interrupt_count: 4,
        path: "sprites/kenobi/slash-0/:index.png"
      },
      slash_1: {
        frame_count: 6,
        interrupt_count: 4,
        path: "sprites/kenobi/slash-1/:index.png"
      },
      throw_0: {
        frame_count: 8,
        throw_frame: 2,
        catch_frame: 6,
        path: "sprites/kenobi/slash-2/:index.png"
      },
      throw_1: {
        frame_count: 9,
        throw_frame: 2,
        catch_frame: 7,
        path: "sprites/kenobi/slash-3/:index.png"
      },
      throw_2: {
        frame_count: 9,
        throw_frame: 2,
        catch_frame: 7,
        path: "sprites/kenobi/slash-4/:index.png"
      },
      slash_5: {
        frame_count: 11,
        path: "sprites/kenobi/slash-5/:index.png"
      },
      slash_6: {
        frame_count: 8,
        interrupt_count: 6,
        path: "sprites/kenobi/slash-6/:index.png"
      }
    }

    r.each.with_index do |(k, v), i|
      v.name               ||= k
      v.index              ||= i

      v.hold_for           ||= 5
      v.duration           ||= v.frame_count * v.hold_for
      v.last_index         ||= v.frame_count - 1

      v.interrupt_count    ||= v.frame_count
      v.interrupt_duration ||= v.interrupt_count * v.hold_for

      v.repeat             ||= false
      v.next_action        ||= r[r.keys[i + 1]]
    end

    r
  end

  def render_player
    flip_horizontally = if state.player.facing == -1
                          true
                        else
                          false
                        end

    player_sprite = { x: state.player.x + 1 - 8,
                      y: state.player.y,
                      w: 16,
                      h: 16,
                      flip_horizontally: flip_horizontally }

    if state.player.action == :standing
      if state.player.y != 0
        if state.player.jump_count <= 1
          outputs[:scene].sprites << { **player_sprite, path: "sprites/kenobi/jumping.png" }
        else
          index = state.player.jump_at.frame_index count: 8, hold_for: 5, repeat: false
          index ||= 7
          outputs[:scene].sprites << { **player_sprite, path: "sprites/kenobi/second-jump/#{index}.png" }
        end
      elsif state.player.dx != 0
        index = state.player.action_at.frame_index count: 4, hold_for: 5, repeat: true
        outputs[:scene].sprites << { **player_sprite, path: "sprites/kenobi/run/#{index}.png" }
      else
        outputs[:scene].sprites << { **player_sprite, path: 'sprites/kenobi/standing.png'}
      end
    else
      v = state.actions_lookup[state.player.action]
      slash_frame_index = state.player.action_at.frame_index count:    v.frame_count,
                                                             hold_for: v.hold_for,
                                                             repeat:   v.repeat
      slash_frame_index ||= v.last_index
      slash_path          = v.path.sub ":index", slash_frame_index.to_s
      outputs[:scene].sprites << { **player_sprite, path: slash_path }
    end
  end

  def calc_input
    if state.player.next_action_queue.length > 2
      raise "Code in calc assums that key length of state.player.next_action_queue will never be greater than 2."
    end

    if inputs.controller_one.key_down.a ||
       inputs.mouse.button_left  ||
       inputs.keyboard.key_down.j ||
       inputs.keyboard.key_down.f
      request_action :attack
    end

    should_update_facing = false
    if state.player.action == :standing
      should_update_facing = true
    else
      key_0 = state.player.next_action_queue.keys[0]
      key_1 = state.player.next_action_queue.keys[1]
      if state.tick_count == key_0
        should_update_facing = true
      elsif state.tick_count == key_1
        should_update_facing = true
      elsif key_0 && key_1 && state.tick_count.between?(key_0, key_1)
        should_update_facing = true
      end
    end

    if should_update_facing && inputs.left_right.sign != state.player.facing.sign
      state.player.dx = 0

      if inputs.left
        state.player.facing = -1
      elsif inputs.right
        state.player.facing = 1
      end

      state.player.dx += 0.1 * inputs.left_right
    end

    if state.player.action == :standing
      state.player.dx += 0.1 * inputs.left_right
      if state.player.dx.abs > state.player.max_speed
        state.player.dx = state.player.max_speed * state.player.dx.sign
      end
    end

    was_jump_requested = inputs.keyboard.key_down.up ||
                         inputs.keyboard.key_down.w  ||
                         inputs.mouse.button_right  ||
                         inputs.controller_one.key_down.up ||
                         inputs.controller_one.key_down.b ||
                         inputs.keyboard.key_down.space

    can_jump = state.player.jump_at.elapsed_time > 20
    if state.player.jump_count <= 1
      can_jump = state.player.jump_at.elapsed_time > 10
    end

    if was_jump_requested && can_jump
      if state.player.action == :slash_6
        state.player.action = :standing
      end
      state.player.dy = 1
      state.player.jump_count += 1
      state.player.jump_at     = state.tick_count
    end
  end

  def calc
    calc_input
    calc_requested_action
    calc_next_action
    calc_sabre
    calc_player_movement

    if state.player.y <= 0 && state.player.dy < 0
      state.player.y = 0
      state.player.dy = 0
      state.player.jump_at = 0
      state.player.jump_count = 0
    end
  end

  def calc_player_movement
    state.player.x += state.player.dx
    state.player.y += state.player.dy
    state.player.dy -= 0.05
    if state.player.y <= 0
      state.player.y = 0
      state.player.dy = 0
      state.player.jump_at = 0
      state.player.jump_count = 0
    end

    if state.player.dx.abs < 0.09
      state.player.dx = 0
    end

    state.player.x = 8  if state.player.x < 8
    state.player.x = 120 if state.player.x > 120
  end

  def calc_requested_action
    return if !state.player.requested_action
    return if state.player.requested_action_at > state.tick_count

    player_action = state.player.action
    player_action_at = state.player.action_at

    # first attack
    if state.player.requested_action == :attack
      if player_action == :standing
        state.player.next_action_queue.clear
        state.player.next_action_queue[state.tick_count] = :slash_0
        state.player.next_action_queue[state.tick_count + state.actions_lookup.slash_0.duration] = :standing
      else
        current_action = state.actions_lookup[state.player.action]
        state.player.next_action_queue.clear
        queue_at = player_action_at + current_action.interrupt_duration
        queue_at = state.tick_count if queue_at < state.tick_count
        next_action = current_action.next_action
        next_action ||= { name: :standing,
                          duration: 4 }
        if next_action
        state.player.next_action_queue[queue_at] = next_action.name
        state.player.next_action_queue[player_action_at +
                                       current_action.interrupt_duration +
                                       next_action.duration] = :standing
        end
      end
    end

    state.player.requested_action = nil
    state.player.requested_action_at = nil
  end

  def calc_sabre
    can_throw_sabre = true
    sabre_throws = [:throw_0, :throw_1, :throw_2]
    if !sabre_throws.include? state.player.action
      state.sabre.facing = nil
      state.sabre.is_active = false
      return
    end

    current_action = state.actions_lookup[state.player.action]
    throw_at = state.player.action_at + (current_action.throw_frame) * 5
    catch_at = state.player.action_at + (current_action.catch_frame) * 5
    if !state.tick_count.between? throw_at, catch_at
      state.sabre.facing = nil
      state.sabre.is_active = false
      return
    end

    state.sabre.facing ||= state.player.facing

    state.sabre.is_active = true

    spline = [
      [  0, 0.25, 0.75, 1.0],
      [1.0, 0.75, 0.25,   0]
    ]

    throw_duration = catch_at - throw_at

    current_progress = args.easing.ease_spline throw_at,
                                               state.tick_count,
                                               throw_duration,
                                               spline

    farthest_sabre_x = 32
    state.sabre.y = state.player.y
    state.sabre.x = state.player.x + farthest_sabre_x * current_progress * state.sabre.facing
  end

  def calc_next_action
    return if !state.player.next_action_queue[state.tick_count]

    state.player.previous_action = state.player.action
    state.player.previous_action_at = state.player.action_at
    state.player.previous_action_ended_at = state.tick_count
    state.player.action = state.player.next_action_queue[state.tick_count]
    state.player.action_at = state.tick_count

    is_air_born = state.player.y != 0

    if state.player.action == :slash_0
      state.player.dy = 0 if state.player.dy > 0
      if is_air_born
        state.player.dy  = 0.5
      else
        state.player.dx += 0.25 * state.player.facing
      end
    elsif state.player.action == :slash_1
      state.player.dy = 0 if state.player.dy > 0
      if is_air_born
        state.player.dy  = 0.5
      else
        state.player.dx += 0.25 * state.player.facing
      end
    elsif state.player.action == :throw_0
      if is_air_born
        state.player.dy  = 1.0
      end

      state.player.dx += 0.5 * state.player.facing
    elsif state.player.action == :throw_1
      if is_air_born
        state.player.dy  = 1.0
      end

      state.player.dx += 0.5 * state.player.facing
    elsif state.player.action == :throw_2
      if is_air_born
        state.player.dy  = 1.0
      end

      state.player.dx += 0.5 * state.player.facing
    elsif state.player.action == :slash_5
      state.player.dy = 0 if state.player.dy < 0
      if is_air_born
        state.player.dy += 1.0
      else
        state.player.dy += 1.0
      end

      state.player.dx += 1.0 * state.player.facing
    elsif state.player.action == :slash_6
      state.player.dy = 0 if state.player.dy > 0
      if is_air_born
        state.player.dy  = -0.5
      end

      state.player.dx += 0.5 * state.player.facing
    end
  end

  def tick
    defaults
    calc
    render
  end
end

$game = Game.new

def tick args
  $game.args = args
  $game.tick
end

$gtk.reset
