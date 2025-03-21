class LevelEditor
  attr_gtk
  attr :mode, :hovered_tile, :selected_tile, :tilesheet_rect

  def initialize
    @tilesheet_rect = { x: 0, y: 0, w: 320, h: 320 }
    @mode = :add
  end

  def tick
    generate_tilesheet
    calc
    render
  end

  def calc
    if inputs.keyboard.x
      @mode = :remove
    else
      @mode = :add
    end

    if !@selected_tile
      @mode = :remove
    elsif @selected_tile.x_ordinal == 0 && @selected_tile.y_ordinal == 0
      @mode = :remove
    end

    if mouse.intersect_rect? @tilesheet_rect
      x_ordinal = mouse.x.idiv(16)
      y_ordinal = mouse.y.idiv(16)
      @hovered_tile = { x_ordinal: mouse.x.idiv(16),
                        x: mouse.x.idiv(16) * 16,
                        y_ordinal: mouse.x.idiv(16),
                        y: mouse.y.idiv(16) * 16,
                        row: 20 - y_ordinal - 1,
                        col: x_ordinal,
                        path: tile_path(20 - y_ordinal - 1, x_ordinal, 20),
                        w: 16,
                        h: 16 }
    else
      @hovered_tile = nil
    end

    if mouse.click && @hovered_tile
      @selected_tile = @hovered_tile
    end

    world_mouse = Camera.to_world_space state.camera, inputs.mouse
    ifloor_x = world_mouse.x.ifloor(16)
    ifloor_y = world_mouse.y.ifloor(16)

    @mouse_world_rect =  { x: ifloor_x,
                           y: ifloor_y,
                           w: 16,
                           h: 16 }

    if @selected_tile
      ifloor_x = world_mouse.x.ifloor(16)
      ifloor_y = world_mouse.y.ifloor(16)
      @selected_tile.x = @mouse_world_rect.x
      @selected_tile.y = @mouse_world_rect.y
    end

    if @mode == :remove && (mouse.click || (mouse.held && mouse.moved))
      state.terrain.reject! { |t| t.intersect_rect? @mouse_world_rect }
      save_terrain args
    elsif @selected_tile && (mouse.click || (mouse.held && mouse.moved))
      if @mode == :add
        state.terrain.reject! { |t| t.intersect_rect? @selected_tile }
        state.terrain << @selected_tile.copy
      else
        state.terrain.reject! { |t| t.intersect_rect? @selected_tile }
      end
      save_terrain args
    end
  end

  def render
    outputs.sprites << { x: 0, y: 0, w: 320, h: 320, path: :tilesheet }

    if @hovered_tile
      outputs.sprites << { x: @hovered_tile.x,
                           y: @hovered_tile.y,
                           w: 16,
                           h: 16,
                           path: :pixel,
                           r: 255, g: 0, b: 0, a: 128 }
    end

    if @selected_tile
      if @mode == :remove
        outputs[:scene].sprites << (Camera.to_screen_space state.camera, @selected_tile).merge(path: :pixel, r: 255, g: 0, b: 0, a: 64)
      elsif @selected_tile
        outputs[:scene].sprites << (Camera.to_screen_space state.camera, @selected_tile)
        outputs[:scene].sprites << (Camera.to_screen_space state.camera, @selected_tile).merge(path: :pixel, r: 0, g: 255, b: 255, a: 64)
      end
    end
  end

  def generate_tilesheet
    return if Kernel.tick_count > 0
    results = []
    rows = 20
    cols = 20
    tile_size = 16
    height = rows * tile_size
    width = cols * tile_size
    rows.map_with_index do |row|
      cols.map_with_index do |col|
        results << {
          x: col * tile_size,
          y: height - row * tile_size - tile_size,
          w: tile_size,
          h: tile_size,
          path: tile_path(row, col, cols)
        }
      end
    end

    outputs[:tilesheet].w = width
    outputs[:tilesheet].h = height
    outputs[:tilesheet].sprites << { x: 0, y: 0, w: width, h: height, path: :pixel, r: 0, g: 0, b: 0 }
    outputs[:tilesheet].sprites << results
  end

  def mouse
    inputs.mouse
  end

  def tile_path row, col, cols
    file_name = (tile_index row, col, cols).to_s.rjust(4, "0")
    "sprites/1-bit-platformer/#{file_name}.png"
  end

  def tile_index row, col, cols
    row * cols + col
  end

  def save_terrain args
    contents = args.state.terrain.uniq.map do |terrain_element|
      "#{terrain_element.x.to_i},#{terrain_element.y.to_i},#{terrain_element.w.to_i},#{terrain_element.h.to_i},#{terrain_element.path}"
    end
    File.write "data/terrain.txt", contents.join("\n")
  end

  def load_terrain args
    args.state.terrain = []
    contents = File.read("data/terrain.txt")
    return if !contents
    args.state.terrain = contents.lines.map do |line|
      l = line.strip
      if l.empty?
        nil
      else
        x, y, w, h, path = l.split ","
        { x: x.to_f, y: y.to_f, w: w.to_f, h: h.to_f, path: path }
      end
    end.compact.to_a.uniq
  end
end
