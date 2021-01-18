# Size of board is always 1280x720

def tick args
  size = 64

  # Draw a checkerboard as a placeholder game board
  i = 0
  j = 0
  while i < 12 do
    while j < 21 do
      args.outputs.solids << [(j*size), (i*size), size, size, 255, 100, 0, ((i+j) % 2 == 0) ? 255 : 0]
      j += 1
    end
    j = 0
    i += 1
  end
  k = 0
  ary = Array.new(220)
  while k < 220
    ary[k] = 1
    if k > 20 and k < 36
      ary[k] = 0
    end
    if k > 40 and k < 56
      ary[k] = 0
    end
    if k > 60 and k < 76
      ary[k] = 0
    end
    if k > 80 and k < 96
      ary[k] = 0
    end
    if k > 100 and k < 116
      ary[k] = 0
    end
    if k > 120 and k < 136
      ary[k] = 0
    end
    if k == 161 and args.state.bot3.hp >= 1
      ary[k] = 0
    end
    if k == 147 and args.state.bot1.hp >= 1
      ary[k] = 0
    end
    if k == 215 and args.state.bot2.hp >= 1
      ary[k] = 0
    end
    k += 1
  end
  ary2 = ary;
  htarget = 161
  target = 160
  targetb = 181
  targetc = 141
  targetd = 162
  target2 = 146
  target2b = 167
  target2c = 148
  htarget2 = 147
  target3 = 214
  target3c = 216
  target3b = 195
  htarget3 = 215
  # player attributes
  args.state.player.x ||= 0
  args.state.player.y ||= 0
  args.state.player.w ||= 64
  args.state.player.h ||= 64
  args.state.player.direction ||= 1
  args.state.player.hp ||= 100
  args.state.player.strength ||= 100
  args.state.player.pos ||= 0

  # bot1 attributes
  args.state.bot1.x ||= 448
  args.state.bot1.y ||= 448
  args.state.bot1.w ||= 64
  args.state.bot1.h ||= 64
  args.state.bot1.direction ||= 1
  args.state.bot1.hp ||= 100
  args.state.bot1.strength ||= 5

  # bot2 attributes
  args.state.bot2.x ||= 960
  args.state.bot2.y ||= 640
  args.state.bot2.w ||= 64
  args.state.bot2.h ||= 64
  args.state.bot2.direction ||= 1
  args.state.bot2.hp ||= 100
  args.state.bot2.strength ||= 8

  # bot3 attributes
  args.state.bot3.x ||= 64
  args.state.bot3.y ||= 512
  args.state.bot3.w ||= 64
  args.state.bot3.h ||= 64
  args.state.bot3.direction ||= 1
  args.state.bot3.hp ||= 100
  args.state.bot3.strength ||= 8

  # obstacle attributes
  args.state.obs1.x ||= 64
  args.state.obs1.y ||= 64
  args.state.obs1.w ||= 960
  args.state.obs1.h ||= 384
  args.state.obs1.direction ||= 1


  @menu_shown ||= :hidden

  # display menu
  if @menu_shown == :hidden
    args.state.menu_button ||= new_button :menu, 1081, 650, "Menu"
    args.outputs.primitives << args.state.menu_button[:primitives]

    if button_clicked? args, args.state.menu_button
      @menu_shown = :visible
    end

  else
    args.state.menu_overlay = [1080, 0, 200, 720, 100, 0,   0, 250]

    # first overlay
    if args.state.menu_overlay
      args.outputs.solids << args.state.menu_overlay

      # move button
      args.state.move_button ||= new_button :move, 1081, 650, "Move"
      args.outputs.primitives << args.state.move_button[:primitives]

      if button_clicked? args, args.state.move_button
        args.gtk.notify! "Move button was clicked!"
      end

      # attack button
      args.state.attack_button ||= new_button :attack, 1081, 600, "Attack"
      args.outputs.primitives << args.state.attack_button[:primitives]

      if button_clicked? args, args.state.attack_button

        if args.state.player.pos+1 == htarget or args.state.player.pos-1 == htarget or args.state.player.pos+20 == htarget or args.state.player.pos-20 == htarget
          damage = rand(100)
          dealt = "#{damage} Damage Dealt!"
          args.gtk.notify! dealt
          args.state.bot3.hp -= damage

        end
        if args.state.player.pos+1 == htarget2 or args.state.player.pos-1 == htarget2 or args.state.player.pos+20 == htarget2 or args.state.player.pos-20 == htarget2
          damage = rand(100)
          dealt = "#{damage} Damage Dealt!"
          args.gtk.notify! dealt

          args.state.bot1.hp -= damage

        end
        if args.state.player.pos+1 == htarget3 or args.state.player.pos-1 == htarget3 or args.state.player.pos+20 == htarget3 or args.state.player.pos-20 == htarget3
          damage = rand(100)
          dealt = "#{damage} Damage Dealt!"
          args.gtk.notify! dealt
          args.state.bot2.hp -= damage

        end
      end

      # items button
      args.state.items_button ||= new_button :items, 1081, 550, "Items"
      args.outputs.primitives << args.state.items_button[:primitives]

      if button_clicked? args, args.state.items_button
        args.state.itemMenu_overlay = [880, 0, 200, 720, 150, 0,   0, 250]
        args.gtk.notify! "Items button was clicked!"
      end

      # second overlay
      if args.state.itemMenu_overlay
        args.outputs.solids << args.state.itemMenu_overlay
        args.outputs.labels << [960, 700, "Items"]

        # create items
        args.state.potion_button ||= new_button :potion, 881, 600, "Potion"
        args.outputs.primitives << args.state.potion_button[:primitives]

        if button_clicked? args, args.state.potion_button
          args.gtk.notify! "Potion Used!"
        end

        args.state.elixer_button ||= new_button :potion, 881, 550, "Elixer"
        args.outputs.primitives << args.state.elixer_button[:primitives]

        if button_clicked? args, args.state.elixer_button
          args.gtk.notify! "Elixer Used!"
        end

      end

      # wait button
      args.state.wait_button ||= new_button :wait, 1081, 500, "Wait"
      args.outputs.primitives << args.state.wait_button[:primitives]

      if button_clicked? args, args.state.wait_button
        args.gtk.notify! "Wait button was clicked!"
      end

      # close button
      args.state.close_button ||= new_button :close, 1081, 450, "Close"
      args.outputs.primitives << args.state.close_button[:primitives]

      # hide menu
      if button_clicked? args, args.state.close_button
        @menu_shown = :hidden
      end

    end
  end

  # left and right movement
  if args.inputs.keyboard.key_down.right and ary[args.state.player.pos+1] == 1 and args.state.player.pos%20 < 19
    args.state.player.direction = 1
    args.state.player.started_running_at = args.state.tick_count
    args.state.player.x += size
    args.state.player.pos += 1
  elsif args.inputs.keyboard.key_down.left and ary[args.state.player.pos-1] == 1 and args.state.player.pos%20 > 0
    args.state.player.direction = -1
    args.state.player.started_running_at = args.state.tick_count
    args.state.player.x -= size
    args.state.player.pos -= 1
  end




  # up and down movement
  if args.inputs.keyboard.key_down.up and ary[args.state.player.pos+20] == 1 and args.state.player.pos < 200
    args.state.player.direction = 1
    args.state.player.started_running_at = args.state.tick_count
    args.state.player.y += size
    args.state.player.pos += 20
  elsif args.inputs.keyboard.key_down.down and ary[args.state.player.pos-20] == 1 and args.state.player.pos >= 20
    args.state.player.direction = -1
    args.state.player.started_running_at = args.state.tick_count
    args.state.player.y -= size
    args.state.player.pos -= 20
  end

  pigga = args.state.player.intersect_rect? args.state.obs1
  if pigga
    args.gtk.notify! "sprites collide!"
    args.state.player.y -= size
  end
  looping = true
  cangoup = false
  cangoright = false
  cangodown = false
  cangoleft = false
  ftarget = 10000
  hold = 9
  testtarget = args.state.player.pos
  if args.state.bot3.hp > 0
    ftarget = (target-testtarget).abs
    hold = target
  end
  if(ftarget > (targetb-testtarget).abs and args.state.bot3.hp > 0)
    ftarget = (targetb-testtarget).abs
    hold = targetb
  end
  if(ftarget > (targetc-testtarget).abs and args.state.bot3.hp > 0)
    ftarget = (targetc-testtarget).abs
    hold = targetc
  end
  if(ftarget > (targetd-testtarget).abs and args.state.bot3.hp > 0)
    ftarget = (targetd-testtarget).abs
    hold = targetd
  end
  if(ftarget > (target2-testtarget).abs and args.state.bot1.hp > 0)
    ftarget = (target2-testtarget).abs
    hold = target2
  end
  if(ftarget > (target2b-testtarget).abs and args.state.bot1.hp > 0)
    ftarget = (target2b-testtarget).abs
    hold = target2b
  end
  if(ftarget > (target2c-testtarget).abs and args.state.bot1.hp > 0)
    ftarget = (target2c-testtarget).abs
    hold = target2c
  end
  if(ftarget > (target3-testtarget).abs and args.state.bot2.hp > 0)
    ftarget = (target3-testtarget).abs
    hold = target3
  end
  if(ftarget > (target3b-testtarget).abs and args.state.bot2.hp > 0)
    ftarget = (target3b-testtarget).abs
    hold = target3b
  end
  if(ftarget > (target3c-testtarget).abs and args.state.bot2.hp > 0)
    ftarget = (target3c-testtarget).abs
    hold = target3c
  end
  if ftarget == 10000
    looping = false
  end
  if args.inputs.keyboard.key_down.f
    while looping and target != testtarget and targetb != testtarget and targetc != testtarget and targetd != testtarget and target2 != testtarget and target2b != testtarget and target2c != testtarget and target3 != testtarget and target3b != testtarget and target3c != testtarget
      cangoup = false
      cangoright = false
      cangodown = false
      cangoleft = false

      if hold-testtarget >= 20 and ary2[args.state.player.pos+20] == 1 and args.state.player.pos < 200
        cangoup = true
      elsif testtarget-hold >= 20 and ary2[args.state.player.pos-20] == 1 and args.state.player.pos > 20
        cangodown = true
        cangoup = false
      elsif hold%20-testtarget%20 > 0 and ary2[args.state.player.pos+1] == 1 and args.state.player.pos%20 < 19
        cangodown = false
        cangoup = false
        cangoright = true
      elsif testtarget%20-hold%20 > 0 and ary2[args.state.player.pos-1] == 1 and args.state.player.pos%20 > 0
        cangodown = false
        cangoup = false
        cangoright = false
        cangoleft = true
      end
      if cangodown == false and cangoup == false and cangoleft == false and cangoright == false
        if ary2[args.state.player.pos+20] == 1  and args.state.player.pos < 200
          cangoup = true
        elsif ary2[args.state.player.pos-20] == 1 and args.state.player.pos > 20
          cangodown = true
          cangoup = false
        elsif ary2[args.state.player.pos+1] == 1 and args.state.player.pos%20 < 19
          cangodown = false
          cangoup = false
          cangoright = true
        elsif ary2[args.state.player.pos-1] == 1 and args.state.player.pos%20 > 0
          cangodown = false
          cangoup = false
          cangoright = false
          cangoleft = true
        end
      end
      if cangodown == true
        args.state.player.direction = -1
        args.state.player.started_running_at = args.state.tick_count
        args.state.player.y -= size
        ary2[args.state.player.pos] = 0
        args.state.player.pos -= 20
        testtarget -= 20

      elsif cangoup == true
        args.state.player.direction = 1
        args.state.player.started_running_at = args.state.tick_count
        args.state.player.y += size
        ary2[args.state.player.pos] = 0
        args.state.player.pos += 20
        testtarget+=20

      elsif cangoright == true
        args.state.player.direction = 1
        args.state.player.started_running_at = args.state.tick_count
        args.state.player.x += size
        ary2[args.state.player.pos] = 0
        args.state.player.pos += 1
        testtarget += 1

      elsif cangoleft == true
        args.state.player.direction = -1
        args.state.player.started_running_at = args.state.tick_count
        args.state.player.x -= size
        ary2[args.state.player.pos] = 0
        args.state.player.pos -= 1
        testtarget -= 1
      end

    end
  end


  #Wrap player around the stage
  if args.state.player.x > 1280
    args.state.player.x = -64
    args.state.player.started_running_at ||= args.state.tick_count
  elsif args.state.player.x < -64
    args.state.player.x = 1280
    args.state.player.started_running_at ||= args.state.tick_count
  end

  if args.state.player.y > 720
    args.state.player.y = -64
    args.state.player.started_running_at ||= args.state.tick_count
  elsif args.state.player.y < -64
    args.state.player.y = 720
    args.state.player.started_running_at ||= args.state.tick_count
  end

  # Display obstacles
  args.outputs.sprites << display_obs1(args)

  #Display the flying dragon and bots
  args.outputs.sprites << display_dragon(args)
  if args.state.bot1.hp >= 1
    args.outputs.sprites << display_bot1(args)
  end
  if args.state.bot2.hp >= 1
    args.outputs.sprites << display_bot2(args)
  end
  if args.state.bot3.hp >= 1
    args.outputs.sprites << display_bot3(args)
  end
  if args.state.bot1.hp <= 0 and args.state.bot3.hp <= 0 and args.state.bot2.hp <= 0
    args.gtk.notify! "You Win!"
  end
end

# helper method to create a button
def new_button id, x, y, text
  # create a hash ("entity") that has some metadata
  # about what it represents
  entity =
    {
      id: id,
      rect: { x: x, y: y, w: 200, h: 50 }
    }

  # for that entity, define the primitives
  # that form it
  entity[:primitives] =
    [
      { x: x, y: y, w: 200, h: 50 }.border,
      { x: x + 75, y: y + 30, text: text }.label
    ]

  entity
end

# helper method for determining if a button was clicked
def button_clicked? args, button
  return false unless args.inputs.mouse.click
  return args.inputs.mouse.point.inside_rect? button[:rect]
end

def display_dragon args
  start_looping_at = 0
  number_of_sprites = 2
  number_of_frames_to_show_each_sprite = 8
  does_sprite_loop = true
  sprite_index = start_looping_at.frame_index number_of_sprites,
                                              number_of_frames_to_show_each_sprite,
                                              does_sprite_loop
  {
    pos: args.state.player.pos,
    x: args.state.player.x,
    y: args.state.player.y,
    w: args.state.player.w,
    h: args.state.player.h,
    path: "sprites/roy-#{sprite_index}.png",
    flip_horizontally: args.state.player.direction < 0
  }
end

def display_bot1 args
  start_looping_at = 0
  number_of_sprites = 6
  number_of_frames_to_show_each_sprite = 4
  does_sprite_loop = true
  sprite_index = start_looping_at.frame_index number_of_sprites,
                                              number_of_frames_to_show_each_sprite,
                                              does_sprite_loop
  {
    x: args.state.bot1.x,
    y: args.state.bot1.y,
    w: args.state.bot1.w,
    h: args.state.bot1.h,
    path: "sprites/dragon-#{sprite_index}.png",
    flip_horizontally: args.state.bot1.direction < 0
  }
end

def display_bot2 args
  start_looping_at = 0
  number_of_sprites = 6
  number_of_frames_to_show_each_sprite = 4
  does_sprite_loop = true
  sprite_index = start_looping_at.frame_index number_of_sprites,
                                              number_of_frames_to_show_each_sprite,
                                              does_sprite_loop
  {
    x: args.state.bot2.x,
    y: args.state.bot2.y,
    w: args.state.bot2.w,
    h: args.state.bot2.h,
    path: "sprites/dragon-#{sprite_index}.png",
    flip_horizontally: args.state.bot2.direction < 0
  }
end

def display_bot3 args
  start_looping_at = 0
  number_of_sprites = 6
  number_of_frames_to_show_each_sprite = 4
  does_sprite_loop = true
  sprite_index = start_looping_at.frame_index number_of_sprites,
                                              number_of_frames_to_show_each_sprite,
                                              does_sprite_loop
  {
    x: args.state.bot3.x,
    y: args.state.bot3.y,
    w: args.state.bot3.w,
    h: args.state.bot3.h,
    path: "sprites/dragon-#{sprite_index}.png",
    flip_horizontally: args.state.bot3.direction < 0
  }
end

def display_obs1 args
  start_looping_at = 0
  number_of_sprites = 1
  number_of_frames_to_show_each_sprite = 8
  does_sprite_loop = true
  sprite_index = start_looping_at.frame_index number_of_sprites,
                                              number_of_frames_to_show_each_sprite,
                                              does_sprite_loop
  {
    x: args.state.obs1.x,
    y: args.state.obs1.y,
    w: args.state.obs1.w,
    h: args.state.obs1.h,
    path: "sprites/water-1.png",
    flip_horizontally: args.state.obs1.direction < 0
  }
end
