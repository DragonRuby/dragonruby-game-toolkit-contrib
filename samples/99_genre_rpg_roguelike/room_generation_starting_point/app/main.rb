#This is an example for a way to generate a simple dungeon
#based off of randomised square rooms and then connecting 
#together via corridors
$game = nil
$gtk.reset

class Game
	attr_gtk
	#this is only ran once when the class is created
  def initialize
    @grid_w = 50
    @grid_h = 40
    @grid = []
	
		@player_x = 0
		@player_y = 0
		@has_enviroment_rendered=false
		#setup and fill grid with walls
    	@grid_w.times.with_index do |x|
    		@grid[x] = []
			@grid_h.times.with_index do |y|
    			@grid[x][y]= 1
    	  	end
    	end
		min_rooms = 2
		max_rooms = 10
		#setup number of rooms that will exist
		@n_rooms = rand(max_rooms - min_rooms) + min_rooms
		puts "n rooms #{@n_rooms}"
		rooms = []
		#define the size of each room
		@n_rooms.times.with_index do |room|
			rooms[room] = make_room 8,10
		end
	
		#clears the walls from where rooms will be 
		rooms.each_with_index do |r,i| 
			(r[:x]..r[:x] + r[:w]).each do |x|
				(r[:y]..r[:y] + r[:h]).each do |y|
					@grid[x][y]= 0
				end
			end
		end
		#create pathways towards the next room
		rooms.each_cons(2) do |(cur_room, next_room)|
			#find the center of each room 
			center_x = cur_room[:x] + cur_room[:w].idiv(2)
			center_y = cur_room[:y] + cur_room[:h].idiv(2)

			next_center_x = next_room[:x] + next_room[:w].idiv(2)
			next_center_y = next_room[:y] + next_room[:h].idiv(2)

			#loops between each rooms X and Y positions 
			#this can be approached differently
			(min(center_x,next_center_x)..max(center_x,next_center_x)).each do |x|
				(min(center_y,next_center_y)..max(center_y,next_center_y)).each do |y|
					#checking if this position is in-line with either rooms x or y centres
					@grid[x][y] = 0 if y == center_y || y == next_center_y || x == center_x || x == next_center_x
				end
			end
		end
		@new_grid = []
		#set new grid to prune unneeded walls to improve performance
		@grid_w.times.with_index do |x|
	    	@new_grid[x] = []
	    	@grid_h.times.with_index do |y|
    			@new_grid[x][y]= @grid[x][y]
			end
	    end
		#set up values
		@grid_w.times.with_index do |x|
    		@grid_h.times.with_index do |y|
				#if surrounded it should not be filled in
				if check_surrounding_tiles x,y
					@grid[x][y] = 0
				end
      		end
    	end
		#this will set the players starting position to a known safe area
		@player_x = rooms[0][:x] + rooms[0][:w].idiv(2)
		@player_y = rooms[0][:y] + rooms[0][:h].idiv(2)
		@grid[@player_x][@player_y] = 2
	end
  
  	#simply returns the larger number
	def max x,y
		return x if x > y
		return y
	end
  	#simply returns the lower number
	def min x,y
		return x if x < y
		return y
	end
  
	def check_surrounding_tiles x,y
		#checking to see if this would go out of bounds and will return false if thats the case 
		top = y + 1 
		return false if top >= @grid_h
		bottom = y - 1
		return false if bottom < 0
		left = x - 1
		return false if left < 0
		right = x + 1
		return false if right >= @grid_w

		#adding up the value of all the surrounding positions
		val = @new_grid[x][top] + @new_grid[x][bottom] + @new_grid[left][y] + @new_grid[right][y] +
		@new_grid[right][bottom] + @new_grid[left][bottom] + @new_grid[left][top] + @new_grid[right][top]
		# as I expect walls to be equal to 1 I know that is should equal 8 if surrounded
		return true if val == 8	
	end
	#defines the position and size of a room
	def make_room max_w,max_h
	{
		x: rand(@grid_w - max_w - 1) + 1,
		y: rand(@grid_h - max_h - 1) + 1,
		w: rand(max_w) + 1,
		h: rand(max_h) + 1,
	}
	end
	#X and Y are grid positions not pixels
	def render_wall x, y
    	boxsize = 16
    	grid_x = (1280 - (@grid_w * boxsize)) / 2
    	grid_y = (720 - ((@grid_h - 2) * boxsize)) / 2
		#static_sprites are not cleared each frame and as the walls do not move they can be static which improves performance
		@args.outputs.static_sprites << [ grid_x + (x*boxsize), (720 - grid_y)- (y * boxsize), boxsize, boxsize, "sprites/wall1.png"]
	end

	#X and Y are grid positions not pixels
	def render_player x, y 
    	boxsize = 16
    	grid_x = (1280 - (@grid_w * boxsize)) / 2
    	grid_y = (720 - ((@grid_h - 2) * boxsize)) / 2
		@args.outputs.sprites << [ grid_x + (x * boxsize), (720 - grid_y)- (y * boxsize), boxsize, boxsize, "sprites/debug.png"]
	end
  
	#loops through the grid and decides when to update it
	#I only render the walls once as static as they will not change
	def render_grid
		@grid_w.times.with_index do |x|
			@grid_h.times.with_index do |y|
				if !@has_enviroment_rendered
    	    		render_wall x, y if @grid[x][y]==1
				end
				render_player x, y if @grid[x][y]==2
    		end
    	end
		@has_enviroment_rendered = true
	end
  
	def render
		render_grid
  	end

	def check_collision x, y
		new_pos_x = @player_x + x
		new_pos_y = @player_y + y

		return false if	new_pos_y >= @grid_h
		return false if	new_pos_y < 0
		return false if new_pos_x < 0
		return false if new_pos_x >= @grid_w
		
		return true if @grid[new_pos_x][new_pos_y] == 0
		return false
	end

	def iterate
		#shorthand keyboard input to make for less typing
		k = args.inputs.keyboard
    	x = 0
		y = 0
		
		#set players direction based on key input  - in y is up dude to the grids
		if k.key_down.w 
			y -= 1
		end
		if k.key_down.s 
			y += 1
		end
		if k.key_down.a 
			x -= 1
		end
		if k.key_down.d 
			x += 1
		end
		#checking if a direction has been set 
		if !(x == 0) || !(y == 0)
			if check_collision x, y 
				#clearing the players old position
				@grid[@player_x][@player_y] = 0
				#updating the new position as setting the player there
				@player_x = @player_x + x
				@player_y = @player_y + y
				@grid[@player_x][@player_y] = 2
			end
		end
	end
	
	
	def tick
		iterate
	  render
		#this can be used to check your framerate 
		#args.outputs.debug<< args.gtk.framerate_diagnostics_primitives
	end

end

#this runs 60 times a second and is where all the code is run 
def tick args
  $game ||=Game.new
  $game.args = args
  $game.tick
end
