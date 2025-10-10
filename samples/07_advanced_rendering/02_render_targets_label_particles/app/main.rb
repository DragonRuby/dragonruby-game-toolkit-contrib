class Game
  attr_gtk

  def initialize
    # keeps track of particle states
    @particles ||= []

    # keeps track of whether a render target for the specific number
    # has been created already
    @created_prefabs ||= {}
  end

  def create_particle_rt! number
    # if the render target for the number has already been created
    # (and cached). return/exit early since we don't want to bust the
    # texture that's already been created for us
    return @created_prefabs[number] if @created_prefabs[number]
    path = number.to_s

    # if it hasn't been created, then create a RT with the name equal to
    # to the number. add it to the lookup of created_prefabs
    @created_prefabs[number] = path

    # set RT properties
    outputs[path].w = 30
    outputs[path].h = 30
    outputs[path].background_color = [0, 0, 0, 0]

    # add the label to the render target
    outputs[path].labels << {
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

    # if the particle was created this frame, skip its render
    # since the RT won't be processed until the next tick
    if particle.created_at == Kernel.tick_count
      nil
    else
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
        number: Numeric.rand(0..100),
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
