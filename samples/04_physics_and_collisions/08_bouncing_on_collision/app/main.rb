INFINITY= 10**10

require 'app/vector2d.rb'
require 'app/peg.rb'
require 'app/block.rb'
require 'app/ball.rb'
require 'app/cannon.rb'


#Method to init default values
def defaults args
  args.state.pegs ||= []
  args.state.blocks ||= []
  args.state.cannon ||= Cannon.new args
  args.state.ball ||= Ball.new args
  args.state.horizontal_offset ||= 0
  init_pegs args
  init_blocks args

  args.state.display_value ||= "test"
end

begin :default_methods
  def init_pegs args
    num_horizontal_pegs = 14
    num_rows = 5

    return unless args.state.pegs.count < num_rows * num_horizontal_pegs

    block_size = 32
    block_spacing = 50
    total_width = num_horizontal_pegs * (block_size + block_spacing)
    starting_offset = (args.grid.w - total_width) / 2 + block_size

    for i in (0...num_rows)
      for j in (0...num_horizontal_pegs)
        row_offset = 0
        if i % 2 == 0
          row_offset = 20
        else
          row_offset = -20
        end
        args.state.pegs.append(Peg.new(j * (block_size+block_spacing) + starting_offset + row_offset, (args.grid.h - block_size * 2) - (i * block_size * 2)-90, block_size))
      end
    end

  end

  def init_blocks args
    return unless args.state.blocks.count < 10

    #Sprites are rotated in degrees, but the Ruby math functions work on radians
    radians_to_degrees = Math::PI / 180

    block_size = 25
    #Rotation angle (in degrees) of the blocks
    rotation = 30
    vertical_offset = block_size * Math.sin(rotation * radians_to_degrees)
    horizontal_offset = (3 * block_size) * Math.cos(rotation * radians_to_degrees)
    center = args.grid.w / 2

    for i in (0...5)
      #Create a ramp of blocks. Not going to be perfect because of the float to integer conversion and anisotropic to isotropic coversion
      args.state.blocks.append(Block.new((center + 100 + (i * horizontal_offset)).to_i, 100 + (vertical_offset * i) + (i * block_size), block_size, rotation))
      args.state.blocks.append(Block.new((center - 100 - (i * horizontal_offset)).to_i, 100 + (vertical_offset * i) + (i * block_size), block_size, -rotation))
    end
  end
end

#Render loop
def render args
  args.outputs.borders << args.state.game_area
  render_pegs args
  render_blocks args
  args.state.cannon.render args
  args.state.ball.draw args
end

begin :render_methods
  #Draw the pegs in a grid pattern
  def render_pegs args
    args.state.pegs.each do |peg|
      peg.draw args
    end
  end

  def render_blocks args
    args.state.blocks.each do |block|
      block.draw args
    end
  end

end

#Calls all methods necessary for performing calculations
def calc args
  args.state.pegs.each do |peg|
    peg.calc args
  end

  args.state.blocks.each do |block|
    block.calc args
  end

  args.state.ball.update args
  args.state.cannon.update args
end

begin :calc_methods

end

def tick args
  defaults args
  render args
  calc args
end
