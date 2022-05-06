$gtk.reset

def coinflip
  rand < 0.5
end

class Game
  attr_accessor :args

  def text_font
    return nil #"rpg.ttf"
  end

  def text_color
    [ 255, 255, 255, 255 ]
  end

  def set_gem_values
    @args.state.gem0 = ((coinflip) ?  100 : 20)
    @args.state.gem1 = ((coinflip) ? -10 : -50)
    @args.state.gem2 = ((coinflip) ? -10 : -30)
    if coinflip
      tmp = @args.state.gem0
      @args.state.gem0 = @args.state.gem1
      @args.state.gem1 = tmp
    end
    if coinflip
      tmp = @args.state.gem1
      @args.state.gem1 = @args.state.gem2
      @args.state.gem2 = tmp
    end
    if coinflip
      tmp = @args.state.gem0
      @args.state.gem0 = @args.state.gem2
      @args.state.gem2 = tmp
    end
  end

  def initialize args
    @args = args
    @args.state.animticks = 0
    @args.state.score = 0
    @args.state.gem_chosen = false
    @args.state.round_finished = false
    @args.state.gem0_x = 197
    @args.state.gem0_y = 720-274
    @args.state.gem1_x = 623
    @args.state.gem1_y = 720-274
    @args.state.gem2_x = 1049
    @args.state.gem2_y = 720-274
    @args.state.hero_sprite = "sprites/herodown100.png"
    @args.state.hero_x = 608
    @args.state.hero_y = 720-656
    set_gem_values
  end

  def render_gem_value x, y, gem
    if @args.state.gem_chosen
      @args.outputs.labels << [ x, y + 96, gem.to_s, 1, 1, *text_color, text_font ]
    end
  end

  def render
    gemsprite = ((@args.state.animticks % 400) < 200) ? 'sprites/gem200.png' : 'sprites/gem400.png'
    @args.outputs.background_color = [ 0, 0, 0, 255 ]
    @args.outputs.sprites << [608, 720-150, 64, 64, 'sprites/oldman.png']
    @args.outputs.sprites << [300, 720-150, 64, 64, 'sprites/fire.png']
    @args.outputs.sprites << [900, 720-150, 64, 64, 'sprites/fire.png']
    @args.outputs.sprites << [@args.state.gem0_x, @args.state.gem0_y, 32, 64, gemsprite]
    @args.outputs.sprites << [@args.state.gem1_x, @args.state.gem1_y, 32, 64, gemsprite]
    @args.outputs.sprites << [@args.state.gem2_x, @args.state.gem2_y, 32, 64, gemsprite]
    @args.outputs.sprites << [@args.state.hero_x, @args.state.hero_y, 64, 64, @args.state.hero_sprite]

    @args.outputs.labels << [ 630, 720-30, "IT'S A SECRET TO EVERYONE.", 1, 1, *text_color, text_font ]
    @args.outputs.labels << [ 50, 720-85, @args.state.score.to_s, 1, 1, *text_color, text_font ]
    render_gem_value @args.state.gem0_x, @args.state.gem0_y, @args.state.gem0
    render_gem_value @args.state.gem1_x, @args.state.gem1_y, @args.state.gem1
    render_gem_value @args.state.gem2_x, @args.state.gem2_y, @args.state.gem2
  end

  def calc
    @args.state.animticks += 16

    return unless @args.state.gem_chosen
    @args.state.round_finished_debounce ||= 60 * 3
    @args.state.round_finished_debounce -= 1
    return if @args.state.round_finished_debounce > 0

    @args.state.gem_chosen = false
    @args.state.hero.sprite[0] = 'sprites/herodown100.png'
    @args.state.hero.sprite[1] = 608
    @args.state.hero.sprite[2] = 656
    @args.state.round_finished_debounce = nil
    set_gem_values
  end

  def walk xdir, ydir, anim
    @args.state.hero_sprite = "sprites/#{anim}#{(((@args.state.animticks % 200) < 100) ? '100' : '200')}.png"
    @args.state.hero_x += 5 * xdir
    @args.state.hero_y += 5 * ydir
  end

  def check_gem_touching gem_x, gem_y, gem
    return if @args.state.gem_chosen
    herorect = [ @args.state.hero_x, @args.state.hero_y, 64, 64 ]
    return if !herorect.intersect_rect?([gem_x, gem_y, 32, 64])
    @args.state.gem_chosen = true
    @args.state.score += gem
    @args.outputs.sounds << ((gem < 0) ? 'sounds/lose.wav' : 'sounds/win.wav')
  end

  def input
    if @args.inputs.keyboard.key_held.left
      walk(-1.0, 0.0, 'heroleft')
    elsif @args.inputs.keyboard.key_held.right
      walk(1.0, 0.0, 'heroright')
    elsif @args.inputs.keyboard.key_held.up
      walk(0.0, 1.0, 'heroup')
    elsif @args.inputs.keyboard.key_held.down
      walk(0.0, -1.0, 'herodown')
    end

    check_gem_touching(@args.state.gem0_x, @args.state.gem0_y, @args.state.gem0)
    check_gem_touching(@args.state.gem1_x, @args.state.gem1_y, @args.state.gem1)
    check_gem_touching(@args.state.gem2_x, @args.state.gem2_y, @args.state.gem2)
  end

  def tick
    input
    calc
    render
  end
end

def tick args
    args.state.game ||= Game.new args
    args.state.game.args = args
    args.state.game.tick
end
