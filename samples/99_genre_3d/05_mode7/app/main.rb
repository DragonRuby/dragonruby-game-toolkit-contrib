include Math

# to use:
# - put a 1024x1024 terrain png as sprites/map.png
# - put four images (or as many as you want) in sprites/xxx.png
# - set up the sprites you want to use in atlases_setup(): filename,width,height
# - place the sprites on the map by modifying sprites_setup(): x,y,atlasid
#   - note that 0,0 is the center of the map

class Mode7
	def atlas_add(img,w,h)
		@atlasImg << img
		@atlasW << w
		@atlasH << h
	end

	def atlases_setup()
		atlas_add("sprites/tree1.png",16,29)
		atlas_add("sprites/tree2.png",16,28)
		atlas_add("sprites/tree3.png",15,30)
		atlas_add("sprites/tree4.png",32,32)
	end

	def camera_change(dx,dy,dz,dir,df)
		@fov += df
		if (dir != 0)
			@angY += dir
			# put the sprite in the center of the 2kx2k rendertarget, and rotate appropriately
			@args.render_target(:land).sprites << {	x: 1024,
													y: 1024,
													anchor_x: 0.5,
													anchor_y: 0.5,
													scale_quality_enum: 0,
													w: 1024,
													h: 1024,
													path: "sprites/map.png",
													angle: @angY
			}
		end
		# deg to rads
		radX = @angX*0.01745329
		radY = @angY*0.01745329
		# update physical x/y of camera based on angle
		@physX -= dx*cos(radY)-dy*sin(radY)
		@physY += dx*sin(radY)+dy*cos(radY)
		# rotate camera to match position on rendertarget
		@camX = @physX*cos(radY)-@physY*sin(radY)+1024
		@camY = @physX*sin(radY)+@physY*cos(radY)+1024
		@camZ += dz
		# set up other calcs for sprites etc
		@camProjectionPlaneYCenter = (360*sin(radX))
		@dirX = sin(radY)
		@dirY = cos(radY)
		@planeX = cos(radY)*@fov
		@planeY = -sin(radY)*@fov
	end

	def floor_draw()
		camX = @camX
		camY = @camY
		top = @camZ-360.0
		for y in (0..359) do
			zRatio = (top*100).fdiv(y-360.0)
			if (zRatio)<2048
				sx = camX-(zRatio/2)
				sy = camY+(zRatio)
				pixelStretch = (1280/zRatio)
				sw = sx+zRatio
				offset = ((sx-sx.floor()))*pixelStretch
				lessWidth = (1-(zRatio-zRatio.floor()))*pixelStretch
				@args.outputs.sprites << {	x: -offset,
											y: y,
											w: 1280+lessWidth+pixelStretch,
											h: 1,
											scale_quality_enum: 0,
											path: :land,
											source_x: sx,
											source_y: sy,
											source_w: zRatio+1,
											source_h: 1 }
			end
		end
	end

	def initialize(args)
		@args = args
		args.gtk.enable_console
		args.render_target(:land).w = 2048
		args.render_target(:land).h = 2048
		@physX = -430.0 # actual location in rectangular grid
		@physY = -135.0
		@camX = 0 # location on the rendertarget after rotation
		@camY = 0
		@camZ = 240
		@fov = 0.5 #66
		@angX = 0 # vertical up/down
		@angY = 0 # angle of the rendertarget
		@dirX = 0
		@dirY = 0
		@planeX = 0
		@planeY = 0
		@landY = 0
		# temp test
		@zMap = []
		@zRatio = []
		@minilength = 0
		@screenX = []
		@screenY = []
		@screenZ = []
		@scale = 5.0
		@imgW = []
		@imgH = []
		@atlasImg = []
		@atlasW = []
		@atlasH = []
		@renderX = []
		@renderY = []
		@renderZ = []
		@renderPath = []
		# camera setting has to be last
		camera_change(0,0,0,0.1,0)
		camera_change(0,0,0,-0.1,0)
		atlases_setup()
		sprites_setup()
	end

	def player_move()
		camera_change( 2, 0, 0, 0, 0) if @args.inputs.keyboard.q
		camera_change(-2, 0, 0, 0, 0) if @args.inputs.keyboard.e
		camera_change( 0, 3, 0, 0, 0) if @args.inputs.keyboard.up
		camera_change( 0,-3, 0, 0, 0) if @args.inputs.keyboard.down
		camera_change( 0, 0, 0,-1, 0) if @args.inputs.keyboard.left
		camera_change( 0, 0, 0, 1, 0) if @args.inputs.keyboard.right
		camera_change( 0, 0,-2, 0, 0) if @args.inputs.keyboard.r
		camera_change( 0, 0, 2, 0, 0) if @args.inputs.keyboard.f
	end

	def render_clear()
		@args.outputs.static_sprites.clear
		@minirender = []
		@minilength = 0
	end

	def render_set()
		@args.outputs.static_sprites << @minirender
	end

	def render_update()
		# update the position of each sprite in the array.
		# remember, this isn't doing any more calcs of movement or anything else, just updating for the camera movement.
		# we could always do a smoothing between an old and new coordinate later if it's an issue.
		invDet = 1.fdiv(@planeX*@dirY-@dirX*@planeY) #required for correct matrix multiplication regardless of frame
		rs = @minirender.size
		for index in 0...rs
			spriteX = @minirender[index].sx-@physX
			spriteY = @minirender[index].sy-@physY
			transformY = invDet*(-@planeY*spriteX+@planeX*spriteY) #this is actually the depth inside the screen, that what Z is in 3D
			if (transformY > 0)
				transformX = invDet*(@dirY*spriteX-@dirX*spriteY)
				spriteScreenX = ((1280/2)*(1+transformX/transformY))
				spriteWidth = 720*(@minirender[index].imgw/(transformY))
				# check if sprite is off screen
				if ((spriteScreenX+spriteWidth) > 0) and ((spriteScreenX-spriteWidth) < 1280)
					spriteHeight = 720*(@minirender[index].imgh/(transformY)) #using 'transformY' instead of the real distance prevents fisheye
					drawStartY = (((@camZ-360)*100)/transformY)+360
					drawStartX = spriteScreenX
					@minirender[index].x = drawStartX
					@minirender[index].y = drawStartY
					@minirender[index].w = spriteWidth
					@minirender[index].h = spriteHeight
				else
					@minirender[index].w = 0
					@minirender[index].h = 0
				end
			else
				@minirender[index].w = 0
				@minirender[index].h = 0
			end
		end
	end

	def sprites_draw()
		# draw sprites back to front
		# every x frames, create the mini array of sprites and link it to the static sprite list
		invDet = 1.fdiv(@planeX*@dirY-@dirX*@planeY) #required for correct matrix multiplication regardless of frame
		rs = @renderX.size
		for index in 0...rs
			spriteX = @renderX[index]-@physX
			spriteY = @renderY[index]-@physY
			transformY = invDet*(-@planeY*spriteX+@planeX*spriteY) #this is actually the depth inside the screen, that what Z is in 3D
			if (transformY > 0)
				transformX = invDet*(@dirY*spriteX-@dirX*spriteY)
				spriteScreenX = ((1280/2)*(1+transformX/transformY))
				spriteWidth = 720*(@imgW[index]/(transformY))
				# check if sprite is off screen
				if ((spriteScreenX+spriteWidth) > -100) and ((spriteScreenX-spriteWidth) < 1380) # allow for a little overlap to cover sprites that come in view before next update
					spriteHeight = 720*(@imgH[index]/(transformY)) #using 'transformY' instead of the real distance prevents fisheye
					drawStartY = (((@camZ-360)*100)/transformY)+360
					drawStartX = spriteScreenX
					minisprite = {	x: drawStartX,
									y: drawStartY,
									sx: @renderX[index],
									sy: @renderY[index],
									z: transformY,
									w: spriteWidth,
									h: spriteHeight,
									imgw: @imgW[index],
									imgh: @imgH[index],
									anchor_x: 0.5,
									anchor_y: 0,
									path: @renderPath[index]}
					if (@minilength == 0)
						@minirender << minisprite
					else
						# insert the element sorted
						j = @minilength-1
						# start from back end
						while (j >= 0) and (@minirender[j].z < transformY)
							@minirender[j+1] = @minirender[j] #shift element right
							j -= 1
						end
						@minirender[j+1] = minisprite #insert element
					end
					@minilength += 1
				end
			end
		end
	end

	def sprites_setup()
		@renderX = []
		@renderY = []
		@renderZ = []
		@renderPath = []
		tx = -64
		while tx < 64
			sprites_setup_helper(tx,63,0)
			sprites_setup_helper(63,tx,1)
			sprites_setup_helper(tx,-64,2)
			sprites_setup_helper(-64,tx,3)
			tx += 2
		end
		sprites_setup_helper(-47,35,0)
		sprites_setup_helper(-47,34,0)
		sprites_setup_helper(-47,33,0)
		sprites_setup_helper(-47,32,0)
		sprites_setup_helper(-46,32,0)
		sprites_setup_helper(-45,32,0)
		sprites_setup_helper(-44,32,0)
		sprites_setup_helper(-43,43,0)
		sprites_setup_helper(-42,43,0)
		sprites_setup_helper(-41,43,0)
		sprites_setup_helper(-40,43,0)
		sprites_setup_helper(-39,43,0)
		sprites_setup_helper(-38,43,0)
		sprites_setup_helper(-37,43,0)
		sprites_setup_helper(-36,43,0)
		sprites_setup_helper(-35,43,0)
		sprites_setup_helper(-34,43,0)
		sprites_setup_helper(-33,43,0)
		sprites_setup_helper(-32,43,0)
		sprites_setup_helper(-8,36,0)
		sprites_setup_helper(-8,37,0)
		sprites_setup_helper(-8,38,0)
		sprites_setup_helper(-8,39,0)
		sprites_setup_helper(-8,40,0)
		sprites_setup_helper(-8,41,0)
		sprites_setup_helper(-8,42,0)
		sprites_setup_helper(-8,43,0)
		sprites_setup_helper(-8,44,0)
		sprites_setup_helper(-8,45,0)
		sprites_setup_helper(-8,46,0)
		sprites_setup_helper(-8,47,0)
		sprites_setup_helper(-8,48,0)
		sprites_setup_helper(-8,49,0)
	end

	def sprites_setup_helper(tx,ty,p)
		@renderX << (tx*8)+4
		@renderY << (ty*8)+4
		@renderZ << 0
		@imgW << @atlasW[p]
		@imgH << @atlasH[p]
		@renderPath << @atlasImg[p]
	end
end

def tick(args)
	args.state.game = Mode7.new(args) if (Kernel.tick_count == 0)
	args.state.game.player_move()
	args.state.game.floor_draw()
	if (Kernel.tick_count.mod(10) == 0)
		args.state.game.render_clear()
		args.state.game.sprites_draw()
		args.state.game.render_set()
	else
		args.state.game.render_update()
	end
	args.outputs.labels << [640, 540, "Keys: Q,W,E,A,S,D,R,F", 5, 1]
end
