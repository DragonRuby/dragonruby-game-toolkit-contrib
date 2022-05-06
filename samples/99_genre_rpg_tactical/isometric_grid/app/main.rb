class Isometric
    attr_accessor :grid, :inputs, :state, :outputs

    def tick
        defaults
        render
        calc
        process_inputs
    end

    def defaults
        state.quantity              ||= 6                                                        #Size of grid
        state.tileSize              ||= [262 / 2, 194 / 2]                                       #width and heigth of orange tiles
        state.tileGrid              ||= []                                                       #Holds ordering of tiles
        state.currentSpriteLocation ||= -1                                                       #Current Sprite hovering location 
        state.tileCords             ||= []                                                       #Physical, rendering cordinates
        state.initCords             ||= [640 - (state.quantity / 2 * state.tileSize[0]), 330]    #Location of tile (0, 0)
        state.sideSize              ||= [state.tileSize[0] / 2, 242 / 2]                         #Purple & green cube face size
        state.mode                  ||= :delete                                                  #Switches between :delete and :insert
        state.spriteSelection       ||= [['river',    0, 0, 262 / 2, 194 / 2],
                                         ['mountain', 0, 0, 262 / 2, 245 / 2],
                                         ['ocean',    0, 0, 262 / 2, 194 / 2]]             #Storage for sprite information
                                                                                           #['name', deltaX, deltaY, sizeW, sizeH]
                                                                                           #^delta refers to distance from tile cords

        #Orders tiles based on tile placement and fancy math. Very left: 0,0. Very bottom: quantity-1, 0, etc
        if state.tileGrid == []
            tempX = 0
            tempY = 0
            tempLeft = false
            tempRight = false
            count = 0
            (state.quantity * state.quantity).times do
                if tempY == 0
                    tempLeft = true
                end
                if tempX == (state.quantity - 1)
                    tempRight = true
                end
                state.tileGrid.push([tempX, tempY, true, tempLeft, tempRight, count])
                    #orderX, orderY, exists?, leftSide, rightSide, order
                tempX += 1
                if tempX == state.quantity
                    tempX = 0
                    tempY += 1
                end
                tempLeft = false
                tempRight = false
                count += 1
            end
        end

        #Calculates physical cordinates for tiles
        if state.tileCords == []
            state.tileCords = state.tileGrid.map do
                |val|
                x = (state.initCords[0]) + ((val[0] + val[1]) * state.tileSize[0] / 2)
                y = (state.initCords[1]) + (-1 * val[0] * state.tileSize[1] / 2) + (val[1] * state.tileSize[1] / 2)
                [x, y, val[2], val[3], val[4], val[5], -1] #-1 represents sprite on top of tile. -1 for now
            end
        end

    end

    def render
        renderBackground
        renderLeft
        renderRight
        renderTiles
        renderObjects
        renderLabels
    end

    def renderBackground
        outputs.solids << [0, 0, 1280, 720, 0, 0, 0]   #Background color
    end

    def renderLeft
        #Shows the pink left cube face
        outputs.sprites << state.tileCords.map do
            |val|
            if val[2] == true && val[3] == true       #Checks if the tile exists and right face needs to be rendered
                [val[0], val[1] + (state.tileSize[1] / 2) - state.sideSize[1], state.sideSize[0],
                state.sideSize[1], 'sprites/leftSide.png']
            end
        end
    end

    def renderRight
        #Shows the green right cube face
        outputs.sprites << state.tileCords.map do
            |val|
            if val[2] == true && val[4] == true        #Checks if it exists & checks if right face needs to be rendered
                [val[0] + state.tileSize[0] / 2, val[1] + (state.tileSize[1] / 2) - state.sideSize[1], state.sideSize[0],
                state.sideSize[1], 'sprites/rightSide.png']
            end
        end
    end

    def renderTiles
        #Shows the tile itself. Important that it's rendered after the two above!
        outputs.sprites << state.tileCords.map do
            |val|
            if val[2] == true     #Chcekcs if tile needs to be rendered
              if val[5] == state.currentSpriteLocation
                [val[0], val[1], state.tileSize[0], state.tileSize[1], 'sprites/selectedTile.png']
              else
                [val[0], val[1], state.tileSize[0], state.tileSize[1], 'sprites/tile.png']
              end
            end
        end
    end

    def renderObjects
        #Renders the sprites on top of the tiles. Order of rendering: top corner to right corner and cascade down until left corner
        #to bottom corner.
        a = (state.quantity * state.quantity) - state.quantity
        iter = 0
        loop do
            if state.tileCords[a][2] == true && state.tileCords[a][6] != -1
                outputs.sprites << [state.tileCords[a][0] + state.spriteSelection[state.tileCords[a][6]][1],
                                    state.tileCords[a][1] + state.spriteSelection[state.tileCords[a][6]][2],
                                    state.spriteSelection[state.tileCords[a][6]][3], state.spriteSelection[state.tileCords[a][6]][4],
                                    'sprites/' + state.spriteSelection[state.tileCords[a][6]][0] + '.png']
            end
            iter += 1
            a    += 1
            a -= state.quantity * 2 if iter == state.quantity
            iter = 0                if iter == state.quantity
            break if a < 0
        end
    end

    def renderLabels
        #Labels
        outputs.labels << [50, 680, 'Click to delete!',             5, 0, 255, 255, 255, 255] if state.mode == :delete
        outputs.labels << [50, 640, 'Press \'i\' for insert mode!', 5, 0, 255, 255, 255, 255] if state.mode == :delete
        outputs.labels << [50, 680, 'Click to insert!',             5, 0, 255, 255, 255, 255] if state.mode == :insert
        outputs.labels << [50, 640, 'Press \'d\' for delete mode!', 5, 0, 255, 255, 255, 255] if state.mode == :insert
    end

    def calc
        calcCurrentHover
    end

    def calcCurrentHover
        #This determines what tile the mouse is hovering (or last hovering) over
        x = inputs.mouse.position.x
        y = inputs.mouse.position.y
        m = (state.tileSize[1] / state.tileSize[0])   #slope
        state.tileCords.map do
            |val|
            #Conditions that makes runtime faster. Checks if the mouse click was between tile dimensions (rectangle collision)
            next unless val[0] < x && x < val[0] + state.tileSize[0]
            next unless val[1] < y && y < val[1] + state.tileSize[1]
            next unless val[2] == true
            tempBool = false
            if x == val[0] + (state.tileSize[0] / 2)
                #The height of a diamond is the height of the diamond, so if x equals that exact point, it must be inside the diamond
                tempBool = true
            elsif x < state.tileSize[0] / 2 + val[0]
                #Uses y = (m) * (x - x1) + y1 to determine the y values for the two diamond lines on the left half of diamond
                tempY1 =      (m * (x - val[0])) + val[1] + (state.tileSize[1] / 2)
                tempY2 = (-1 * m * (x - val[0])) + val[1] + (state.tileSize[1] / 2)
                #Checks to see if the mouse click y value is between those temp y values
                tempBool = true if y < tempY1 && y > tempY2
            elsif x > state.tileSize[0] / 2 + val[0]
                #Uses y = (m) * (x - x1) + y1 to determine the y values for the two diamond lines on the right half of diamond
                tempY1 =      (m * (x - val[0] - (state.tileSize[0] / 2))) + val[1]
                tempY2 = (-1 * m * (x - val[0] - (state.tileSize[0] / 2))) + val[1] + state.tileSize[1]
                #Checks to see if the mouse click y value is between those temp y values
                tempBool = true if y > tempY1 && y < tempY2
            end

            if tempBool == true
                state.currentSpriteLocation = val[5]         #Current sprite location set to the order value
            end
        end
    end

    def process_inputs
        #Makes development much faster and easier
        if inputs.keyboard.key_up.r
            $dragon.reset
        end
        checkTileSelected
        switchModes
    end

    def checkTileSelected
        if inputs.mouse.down
            x = inputs.mouse.down.point.x
            y = inputs.mouse.down.point.y
            m = (state.tileSize[1] / state.tileSize[0])   #slope
            state.tileCords.map do
                |val|
                #Conditions that makes runtime faster. Checks if the mouse click was between tile dimensions (rectangle collision)
                next unless val[0] < x && x < val[0] + state.tileSize[0]
                next unless val[1] < y && y < val[1] + state.tileSize[1]
                next unless val[2] == true
                tempBool = false
                if x == val[0] + (state.tileSize[0] / 2)
                    #The height of a diamond is the height of the diamond, so if x equals that exact point, it must be inside the diamond
                    tempBool = true
                elsif x < state.tileSize[0] / 2 + val[0]
                    #Uses y = (m) * (x - x1) + y1 to determine the y values for the two diamond lines on the left half of diamond
                    tempY1 =      (m * (x - val[0])) + val[1] + (state.tileSize[1] / 2)
                    tempY2 = (-1 * m * (x - val[0])) + val[1] + (state.tileSize[1] / 2)
                    #Checks to see if the mouse click y value is between those temp y values
                    tempBool = true if y < tempY1 && y > tempY2
                elsif x > state.tileSize[0] / 2 + val[0]
                    #Uses y = (m) * (x - x1) + y1 to determine the y values for the two diamond lines on the right half of diamond
                    tempY1 =      (m * (x - val[0] - (state.tileSize[0] / 2))) + val[1]
                    tempY2 = (-1 * m * (x - val[0] - (state.tileSize[0] / 2))) + val[1] + state.tileSize[1]
                    #Checks to see if the mouse click y value is between those temp y values
                    tempBool = true if y > tempY1 && y < tempY2
                end

                if tempBool == true
                    if state.mode == :delete
                        val[2] = false
                        state.tileGrid[val[5]][2]  = false      #Unnecessary because never used again but eh, I like consistency
                        state.tileCords[val[5]][2] = false      #Ensures that the tile isn't rendered
                        unless state.tileGrid[val[5]][0] == 0   #If tile is the left most tile in the row, right doesn't get rendered
                            state.tileGrid[val[5] - 1][4] = true            #Why the order value is amazing
                            state.tileCords[val[5] - 1][4] = true
                        end
                        unless state.tileGrid[val[5]][1] == state.quantity - 1     #Same but left side
                            state.tileGrid[val[5] + state.quantity][3] = true
                            state.tileCords[val[5] + state.quantity][3] = true
                        end
                    elsif state.mode == :insert
                        #adds the current sprite value selected to tileCords. (changes from the -1 earlier)
                        val[6] = rand(state.spriteSelection.length)
                    end
                end
            end
        end
    end

    def switchModes
        #Switches between insert and delete modes
        if inputs.keyboard.key_up.i && state.mode == :delete
            state.mode = :insert
            inputs.keyboard.clear
        elsif inputs.keyboard.key_up.d && state.mode == :insert
            state.mode = :delete
            inputs.keyboard.clear
        end
    end

end

$isometric = Isometric.new

def tick args
    $isometric.grid    = args.grid
    $isometric.inputs  = args.inputs
    $isometric.state   = args.state
    $isometric.outputs = args.outputs
    $isometric.tick
end
