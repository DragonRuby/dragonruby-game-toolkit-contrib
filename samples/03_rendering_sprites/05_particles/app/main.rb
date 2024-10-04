def tick args
  # Set the background color to black
  args.outputs.background_color = [0, 0, 0]

  # Initialize the particle queue if it doesn't exist
  args.state.particle_queue ||= []

  # Add a new particle to the queue if the mouse is clicked
  if args.inputs.mouse.click || args.inputs.mouse.held
    args.state.particle_queue << {
      x: args.inputs.mouse.x,    # Set the x position to the mouse's x position
      y: args.inputs.mouse.y,    # Set the y position to the mouse's y position
      emission_speed: 5,         # Set the emission speed to 5
      emission_angle: rand(360), # Set the emission angle to a random angle
      r: 128,                    # Set the red color to 128
      g: rand(128) + 128,        # Set the green color to a random value between 128 and 255
      b: rand(128) + 128,        # Set the blue color to a random value between 128 and 255
    }
  end

  # Update the particles
  args.state.particle_queue.each do |particle|
    # initialize default values for particle
    particle.a ||= 255
    particle.path ||= :solid
    particle.w ||= 5
    particle.h ||= 5
    particle.anchor_x ||= 0.5
    particle.anchor_y ||= 0.5

    # initialize dx and dy of particle based on the emission speed and angle
    particle.dx ||= particle.emission_speed * particle.emission_angle.vector_x
    particle.dy ||= particle.emission_speed * particle.emission_angle.vector_y

    # update the particle's position based on the dx and dy
    particle.x += particle.dx
    particle.y += particle.dy

    # decrease the speed of the particle
    particle.dx *= 0.95
    particle.dy *= 0.95

    # if the particle's speed is less than 1.0, decrease the alpha value
    if particle.dx.abs < 1.0 && particle.dy.abs < 1.0
      particle.a -= 5
    end
  end

  # Remove particles with an alpha value less than or equal to 0
  args.state.particle_queue.reject! do |particle|
    particle.a <= 0
  end

  args.outputs.labels << {
    x: 640,
    y: 720,
    text: "Click and hold the mouse to create particles.",
    r: 255,
    g: 255,
    b: 255,
    anchor_x: 0.5,
    anchor_y: 1.0,
  }

  # Render the particles
  args.outputs.primitives << args.state.particle_queue
end

GTK.reset
