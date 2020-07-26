# coding: utf-8
################################
#  So I was working on a snake game while
#  learning DragonRuby, and at some point I had a thought
#  what if I use "😀" as a function name, surely it wont work right...?
#  RIGHT....?
#  BUT IT DID, IT WORKED
#  it all went downhill from then
#  Created by Anton K. (ai Doge)
#  https://gist.github.com/scorp200
#############LICENSE############
#  Feel free to use this anywhere and however you want
#  You can sell this to EA for $1,000,000 if you want, its completely free.
#  Just rememeber you are helping this... thing... to spread...
#  ALSO! I am not liable for any mental, physical or financial damage caused.
#############LICENSE############


class Array
  #Helper function
  def move! vector
    self.x += vector.x
    self.y += vector.y
    return self
  end

  #Helper function to draw snake body
  def draw! 🎮, 📺, color
    translate 📺.solids, 🎮.⛓, [self.x * 🎮.⚖️ + 🎮.🛶 / 2, self.y * 🎮.⚖️ + 🎮.🛶 / 2, 🎮.⚖️ - 🎮.🛶, 🎮.⚖️ - 🎮.🛶, color]
  end

  #This is where it all started, I was trying to find  good way to multiply a map by a number, * is already used so is **
  #I kept trying different combinations of symbols, when suddenly...
  def 😀 value
    self.map {|d| d * value}
  end
end

#Draw stuff with an offset
def translate output_collection, ⛓, what
  what.x += ⛓.x
  what.y += ⛓.y
  output_collection << what
end

BLUE = [33, 150, 243]
RED = [244, 67, 54]
GOLD = [255, 193, 7]
LAST = 0

def tick args
  defaults args.state
  render args.state, args.outputs
  input args.state, args.inputs
  update args.state
end

def update 🎮
  #Update every 10 frames
  if 🎮.tick_count.mod_zero? 10
    #Add new snake body piece at head's location
    🎮.🐍 << [*🎮.🤖]
    #Assign Next Direction to Direction
    🎮.🚗 = *🎮.🚦

    #Trim the snake a bit if its longer than current size
    if 🎮.🐍.length > 🎮.🛒
      🎮.🐍 = 🎮.🐍[-🎮.🛒..-1]
    end

    #Move the head in the Direction
    🎮.🤖.move! 🎮.🚗

    #If Head is outside the playing field, or inside snake's body restart game
    if 🎮.🤖.x < 0 || 🎮.🤖.x >= 🎮.🗺.x || 🎮.🤖.y < 0 || 🎮.🤖.y >= 🎮.🗺.y || 🎮.🚗 != [0, 0] && 🎮.🐍.any? {|s| s == 🎮.🤖}
      LAST = 🎮.💰
      🎮.as_hash.clear
      return
    end

    #If head lands on food add size and score
    if 🎮.🤖 == 🎮.🍎
      🎮.🛒 += 1
      🎮.💰 += (🎮.🛒 * 0.8).floor.to_i + 5
      spawn_🍎 🎮
      puts 🎮.🍎
    end
  end

  #Every second remove 1 point
  if 🎮.💰 > 0 && 🎮.tick_count.mod_zero?(60)
    🎮.💰 -= 1
  end
end

def spawn_🍎 🎮
  #Food
  🎮.🍎 ||= [*🎮.🤖]
  #Randomly spawns food inside the playing field, keep doing this if the food keeps landing on the snake's body
  while 🎮.🐍.any? {|s| s == 🎮.🍎} || 🎮.🍎 == 🎮.🤖 do
    🎮.🍎 = [rand(🎮.🗺.x), rand(🎮.🗺.y)]
  end
end

def render 🎮, 📺
  #Paint the background black
  📺.solids << [0, 0, 1280, 720, 0, 0, 0, 255]
  #Draw a border for the playing field
  translate 📺.borders, 🎮.⛓, [0, 0, 🎮.🗺.x * 🎮.⚖️, 🎮.🗺.y * 🎮.⚖️, 255, 255, 255]

  #Draw the snake's body
  🎮.🐍.map do |🐍| 🐍.draw! 🎮, 📺, BLUE end
  #Draw the head
  🎮.🤖.draw! 🎮, 📺, BLUE
  #Draw the food
  🎮.🍎.draw! 🎮, 📺, RED

  #Draw current score
  translate 📺.labels, 🎮.⛓, [5, 715, "Score: #{🎮.💰}", GOLD]
  #Draw your last score, if any
  translate 📺.labels, 🎮.⛓, [[*🎮.🤖.😀(🎮.⚖️)].move!([0, 🎮.⚖️ * 2]), "Your Last score is #{LAST}", 0, 1, GOLD] unless LAST == 0 || 🎮.🚗 != [0, 0]
  #Draw starting message, only if Direction is 0
  translate 📺.labels, 🎮.⛓, [🎮.🤖.😀(🎮.⚖️), "Press any Arrow key to start", 0, 1, GOLD] unless 🎮.🚗 != [0, 0]
end

def input 🎮, 🕹
  #Left and Right keyboard input, only change if X direction is 0
  if 🕹.keyboard.key_held.left && 🎮.🚗.x == 0
    🎮.🚦 = [-1, 0]
  elsif 🕹.keyboard.key_held.right && 🎮.🚗.x == 0
    🎮.🚦 = [1, 0]
  end

  #Up and Down keyboard input, only change if Y direction is 0
  if 🕹.keyboard.key_held.up && 🎮.🚗.y == 0
    🎮.🚦 = [0, 1]
  elsif 🕹.keyboard.key_held.down && 🎮.🚗.y == 0
    🎮.🚦 = [0, -1]
  end
end

def defaults 🎮
  #Playing field size
  🎮.🗺 ||= [20, 20]
  #Scale for drawing, screen height / Field height
  🎮.⚖️ ||= 720 / 🎮.🗺.y
  #Offset, offset all rendering to the center of the screen
  🎮.⛓ ||= [(1280 - 720).fdiv(2), 0]
  #Padding, make the snake body slightly smaller than the scale
  🎮.🛶 ||= (🎮.⚖️ * 0.2).to_i
  #Snake Size
  🎮.🛒 ||= 3
  #Snake head, the only part we are actually controlling
  🎮.🤖 ||= [🎮.🗺.x / 2, 🎮.🗺.y / 2]
  #Snake body map, follows the head
  🎮.🐍 ||= []
  #Direction the head moves to
  🎮.🚗 ||= [0, 0]
  #Next_Direction, during input check only change this variable and then when game updates asign this to Direction
  🎮.🚦 ||= [*🎮.🚗]
  #Your score
  🎮.💰 ||= 0
  #Spawns Food randomly
  spawn_🍎(🎮) unless 🎮.🍎?
end
