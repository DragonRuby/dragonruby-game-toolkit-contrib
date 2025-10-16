class Game
  attr_gtk

  def initialize
    # keeps track of particle states
    @particles ||= []
  end

  def create_particle_rt! number
    # if the render target status is queued then return nil until it's ready (a queued render target
    # means that a request has been made to generate the texture, but it hasn't been created yet/isn't ready)
    return outputs.render_targets[number].path if outputs.render_targets.queued? number

    # set RT properties
    outputs[number].w = 30
    outputs[number].h = 30
    outputs[number].background_color = [0, 0, 0, 0]

    # add the label to the render target
    outputs[number].labels << {
      x: 15,
      y: 15,
      text: number.to_s,
      anchor_x: 0.5,
      anchor_y: 0.5,
      size_px: 30
    }
  end

  # returns the particle prefab
  def particle_prefab particle
    # create the rt for the particle (this will return/no-op if the RT
    # has already been created)
    path = create_particle_rt! particle.number

    # query args.outputs.render_targets to get the current status of the texture
    # if it's ready then send it out to draw
    if outputs.render_targets.ready? path
      # return a prefab that represents the RT/label as a sprite
      { x: particle.x,
        y: particle.y,
        w: 30,
        h: 30,
        anchor_x: 0.5,
        anchor_y: 0.5,
        path: path,
        a: particle.a,
        angle: particle.angle }
    end
  end

  def tick
    outputs.labels << {
      x: 640,
      y: 360,
      text: "click to create spinning label particles",
      anchor_x: 0.5,
      anchor_y: 0.5
    }

    # if the mouse is clicked, add a particle
    if inputs.mouse.click
      @particles << {
        x: inputs.mouse.x,
        y: inputs.mouse.y,
        created_at: Kernel.tick_count,
        number: Numeric.rand(1..100),
        a: 255,
        angle: 0
      }
    end

    # process each particle setting their alpha
    # make them spin, and set their y value
    @particles.each do |particle|
      particle.a -= 5
      particle.angle += 10
      particle.y += 3
    end

    # reject all particles with an alpha less than equal to 0
    @particles.reject! do |particle|
      particle.a <= 0
    end

    # for each particle, construct a prefab
    outputs.sprites << @particles.map do |particle|
      particle_prefab(particle)
    end
  end
end

def tick args
  $game ||= Game.new
  $game.args = args
  $game.tick
end

def reset args
  $game = nil
end
