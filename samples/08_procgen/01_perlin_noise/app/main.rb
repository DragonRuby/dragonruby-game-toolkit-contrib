PERLIN_SIZE = 128
RENDER_SIZE = 1280.fdiv(5)

def boot args
  args.state = {}
end

def tick args
  init_perlin_noise_results args

  args.outputs.background_color = [30, 30, 30]

  args.outputs.primitives << { x: 0 * RENDER_SIZE, y: 360 + RENDER_SIZE / 2 + 16, text: "perlin_noise", anchor_y: 0.5, r: 255, g: 255, b: 255, size_px: 16 }
  args.outputs.primitives << { x: 0 * RENDER_SIZE, y: 360, anchor_y: 0.5, w: RENDER_SIZE, h: RENDER_SIZE, path: :perlin_noise }

  args.outputs.primitives << { x: 1 * RENDER_SIZE, y: 360 + RENDER_SIZE / 2 + 16, text: "perlin_noise_seed", anchor_y: 0.5, r: 255, g: 255, b: 255, size_px: 16 }
  args.outputs.primitives << { x: 1 * RENDER_SIZE, y: 360, anchor_y: 0.5, w: RENDER_SIZE, h: RENDER_SIZE, path: :perlin_noise_seed }

  args.outputs.primitives << { x: 2 * RENDER_SIZE, y: 360 + RENDER_SIZE / 2 + 16, text: "perlin_ridge_noise", anchor_y: 0.5, r: 255, g: 255, b: 255, size_px: 16 }
  args.outputs.primitives << { x: 2 * RENDER_SIZE, y: 360, anchor_y: 0.5, w: RENDER_SIZE, h: RENDER_SIZE, path: :perlin_ridge_noise }

  args.outputs.primitives << { x: 3 * RENDER_SIZE, y: 360 + RENDER_SIZE / 2 + 16, text: "perlin_fbm_noise", anchor_y: 0.5, r: 255, g: 255, b: 255, size_px: 16 }
  args.outputs.primitives << { x: 3 * RENDER_SIZE, y: 360, anchor_y: 0.5, w: RENDER_SIZE, h: RENDER_SIZE, path: :perlin_fbm_noise }

  args.outputs.primitives << { x: 4 * RENDER_SIZE, y: 360 + RENDER_SIZE / 2 + 16, text: "perlin_turbulence_noise", anchor_y: 0.5, r: 255, g: 255, b: 255, size_px: 16 }
  args.outputs.primitives << { x: 4 * RENDER_SIZE, y: 360, anchor_y: 0.5, w: RENDER_SIZE, h: RENDER_SIZE, path: :perlin_turbulence_noise }
end

def init_perlin_noise_results args
  return if args.state.results

  args.state.results = {}
  args.state.results[:perlin_noise] = {}
  args.state.results[:perlin_noise_seed] = {}
  args.state.results[:perlin_ridge_noise] = {}
  args.state.results[:perlin_fbm_noise] = {}
  args.state.results[:perlin_turbulence_noise] = {}

  PERLIN_SIZE.times do |x|
    PERLIN_SIZE.times do |y|
      init_results_perlin_noise args, x, y
      init_results_perlin_noise_seed args, x, y
      init_results_perlin_ridge_noise args, x, y
      init_results_perlin_fbm_noise args, x, y
      init_results_perlin_turbulence_noise args, x, y
    end
  end

  init_render_target args, :perlin_noise
  init_render_target args, :perlin_noise_seed
  init_render_target args, :perlin_ridge_noise
  init_render_target args, :perlin_fbm_noise
  init_render_target args, :perlin_turbulence_noise
end

def init_results_perlin_noise_seed args, x, y
  normalized_x = (x - PERLIN_SIZE.idiv(2)).fdiv(PERLIN_SIZE)
  normalized_y = (y - PERLIN_SIZE.idiv(2)).fdiv(PERLIN_SIZE)
  normalized_z = 0
  wrap_x = 0
  wrap_y = 0
  wrap_z = 0
  seed = DR.rng_seed
  args.state.results[:perlin_noise_seed][x] ||= {}
  args.state.results[:perlin_noise_seed][x][y] = Geometry.perlin_noise_seed(normalized_x,
                                                                            normalized_y,
                                                                            normalized_z,
                                                                            wrap_x,
                                                                            wrap_y,
                                                                            wrap_z,
                                                                            seed)
end

def init_results_perlin_noise args, x, y
  normalized_x = (x - PERLIN_SIZE.idiv(2)).fdiv(PERLIN_SIZE)
  normalized_y = (y - PERLIN_SIZE.idiv(2)).fdiv(PERLIN_SIZE)
  normalized_z = 0
  wrap_x = 0
  wrap_y = 0
  wrap_z = 0
  args.state.results[:perlin_noise][x] ||= {}
  args.state.results[:perlin_noise][x][y] = Geometry.perlin_noise(normalized_x,
                                                                  normalized_y,
                                                                  normalized_z,
                                                                  wrap_x,
                                                                  wrap_y,
                                                                  wrap_z)
end


def init_results_perlin_ridge_noise args, x, y
  normalized_x = (x - PERLIN_SIZE.idiv(2)).fdiv(PERLIN_SIZE)
  normalized_y = (y - PERLIN_SIZE.idiv(2)).fdiv(PERLIN_SIZE)
  normalized_z = 0
  lacunarity = 2.0
  gain = 1.0
  offset = 1.0
  octaves = 3
  args.state.results[:perlin_ridge_noise][x] ||= {}
  args.state.results[:perlin_ridge_noise][x][y] = Geometry.perlin_ridge_noise(normalized_x,
                                                                              normalized_y,
                                                                              normalized_z,
                                                                              lacunarity,
                                                                              gain,
                                                                              offset,
                                                                              octaves)
end


def init_results_perlin_fbm_noise args, x, y
  normalized_x = (x - PERLIN_SIZE.idiv(2)).fdiv(PERLIN_SIZE)
  normalized_y = (y - PERLIN_SIZE.idiv(2)).fdiv(PERLIN_SIZE)
  normalized_z = 0
  lacunarity = 10.0
  gain = 0.25
  octaves = 6
  args.state.results[:perlin_fbm_noise][x] ||= {}
  args.state.results[:perlin_fbm_noise][x][y] = Geometry.perlin_fbm_noise(normalized_x,
                                                                          normalized_y,
                                                                          normalized_z,
                                                                          lacunarity,
                                                                          gain,
                                                                          octaves)
end


def init_results_perlin_turbulence_noise args, x, y
  normalized_x = (x - PERLIN_SIZE.idiv(2)).fdiv(PERLIN_SIZE)
  normalized_y = (y - PERLIN_SIZE.idiv(2)).fdiv(PERLIN_SIZE)
  normalized_z = 0
  lacunarity = 5.0
  gain = 0.50
  octaves = 6
  args.state.results[:perlin_turbulence_noise][x] ||= {}
  args.state.results[:perlin_turbulence_noise][x][y] = Geometry.perlin_turbulence_noise(normalized_x,
                                                                                        normalized_y,
                                                                                        normalized_z,
                                                                                        lacunarity,
                                                                                        gain,
                                                                                        octaves)
end

def init_render_target args, key
  args.outputs[key].set w: PERLIN_SIZE,
                        h: PERLIN_SIZE,
                        background_color: [0, 0, 0]

  PERLIN_SIZE.times do |x|
    PERLIN_SIZE.times do |y|
      gray_color = 128 + 128 * args.state.results[key][x][y]
      args.outputs[key] << { x: x,
                             y: y,
                             w: 1,
                             h: 1,
                             path: :solid,
                             r: gray_color,
                             g: gray_color,
                             b: gray_color }
    end
  end
end

def reset args
  DR.set_rng Numeric.rand(1000)
end

DR.reset
