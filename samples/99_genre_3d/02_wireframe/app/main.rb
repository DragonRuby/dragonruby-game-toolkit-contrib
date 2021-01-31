def tick args
  args.state.model   ||= Object3D.new('data/shuttle.off')
  args.state.mtx     ||= rotate3D(0, 0, 0)
  args.state.inv_mtx ||= rotate3D(0, 0, 0)
  delta_mtx          = rotate3D(args.inputs.up_down * 0.01, input_roll(args) * 0.01, args.inputs.left_right * 0.01)
  args.outputs.lines << args.state.model.edges
  args.state.model.fast_3x3_transform! args.state.inv_mtx
  args.state.inv_mtx = mtx_mul(delta_mtx.transpose, args.state.inv_mtx)
  args.state.mtx     = mtx_mul(args.state.mtx, delta_mtx)
  args.state.model.fast_3x3_transform! args.state.mtx
  args.outputs.background_color = [0, 0, 0]
  args.outputs.debug << args.gtk.framerate_diagnostics_primitives
end

def input_roll args
  roll = 0
  roll += 1 if args.inputs.keyboard.e
  roll -= 1 if args.inputs.keyboard.q
  roll
end

def rotate3D(theta_x = 0.1, theta_y = 0.1, theta_z = 0.1)
  c_x, s_x = Math.cos(theta_x), Math.sin(theta_x)
  c_y, s_y = Math.cos(theta_y), Math.sin(theta_y)
  c_z, s_z = Math.cos(theta_z), Math.sin(theta_z)
  rot_x    = [[1, 0, 0], [0, c_x, -s_x], [0, s_x, c_x]]
  rot_y    = [[c_y, 0, s_y], [0, 1, 0], [-s_y, 0, c_y]]
  rot_z    = [[c_z, -s_z, 0], [s_z, c_z, 0], [0, 0, 1]]
  mtx_mul(mtx_mul(rot_x, rot_y), rot_z)
end

def mtx_mul(a, b)
  is = (0...a.length)
  js = (0...b[0].length)
  ks = (0...b.length)
  is.map do |i|
    js.map do |j|
      ks.map do |k|
        a[i][k] * b[k][j]
      end.reduce(&:plus)
    end
  end
end

class Object3D
  attr_reader :vert_count, :face_count, :edge_count, :verts, :faces, :edges

  def initialize(path)
    @vert_count = 0
    @face_count = 0
    @edge_count = 0
    @verts      = []
    @faces      = []
    @edges      = []
    _init_from_file path
  end

  def _init_from_file path
    file_lines = $gtk.read_file(path).split("\n")
                     .reject { |line| line.start_with?('#') || line.split(' ').length == 0 } # Strip out simple comments and blank lines
                     .map { |line| line.split('#')[0] } # Strip out end of line comments
                     .map { |line| line.split(' ') } # Tokenize by splitting on whitespace
    raise "OFF file did not start with OFF." if file_lines.shift != ["OFF"] # OFF meshes are supposed to begin with "OFF" as the first line.
    raise "<NVertices NFaces NEdges> line malformed" if file_lines[0].length != 3 # The second line needs to have 3 numbers. Raise an error if it doesn't.
    @vert_count, @face_count, @edge_count = file_lines.shift&.map(&:to_i) # Update the counts
    # Only the vertex and face counts need to be accurate. Raise an error if they are inaccurate.
    raise "Incorrect number of vertices and/or faces (Parsed VFE header: #{@vert_count} #{@face_count} #{@edge_count})" if file_lines.length != @vert_count + @face_count
    # Grab all the lines describing vertices.
    vert_lines = file_lines[0, @vert_count]
    # Grab all the lines describing faces.
    face_lines = file_lines[@vert_count, @face_count]
    # Create all the vertices
    @verts = vert_lines.map_with_index { |line, id| Vertex.new(line, id) }
    # Create all the faces
    @faces = face_lines.map { |line| Face.new(line, @verts) }
    # Create all the edges
    @edges = @faces.flat_map(&:edges).uniq do |edge|
      sorted = edge.sorted
      [sorted.point_a, sorted.point_b]
    end
  end

  def fast_3x3_transform! mtx
    @verts.each { |vert| vert.fast_3x3_transform! mtx }
  end
end

class Face

  attr_reader :verts, :edges

  def initialize(data, verts)
    vert_count = data[0].to_i
    vert_ids   = data[1, vert_count].map(&:to_i)
    @verts     = vert_ids.map { |i| verts[i] }
    @edges     = []
    (0...vert_count).each { |i| @edges[i] = Edge.new(verts[vert_ids[i - 1]], verts[vert_ids[i]]) }
    @edges.rotate! 1
  end
end

class Edge
  attr_reader :point_a, :point_b

  def initialize(point_a, point_b)
    @point_a = point_a
    @point_b = point_b
  end

  def sorted
    @point_a.id < @point_b.id ? self : Edge.new(@point_b, @point_a)
  end

  def draw_override ffi
    ffi.draw_line(@point_a.render_x, @point_a.render_y, @point_b.render_x, @point_b.render_y, 255, 0, 0, 128)
    ffi.draw_line(@point_a.render_x+1, @point_a.render_y, @point_b.render_x+1, @point_b.render_y, 255, 0, 0, 128)
    ffi.draw_line(@point_a.render_x, @point_a.render_y+1, @point_b.render_x, @point_b.render_y+1, 255, 0, 0, 128)
    ffi.draw_line(@point_a.render_x+1, @point_a.render_y+1, @point_b.render_x+1, @point_b.render_y+1, 255, 0, 0, 128)
  end

  def primitive_marker
    :line
  end
end

class Vertex
  attr_accessor :x, :y, :z, :id

  def initialize(data, id)
    @x  = data[0].to_f
    @y  = data[1].to_f
    @z  = data[2].to_f
    @id = id
  end

  def fast_3x3_transform! mtx
    _x, _y, _z = @x, @y, @z
    @x         = mtx[0][0] * _x + mtx[0][1] * _y + mtx[0][2] * _z
    @y         = mtx[1][0] * _x + mtx[1][1] * _y + mtx[1][2] * _z
    @z         = mtx[2][0] * _x + mtx[2][1] * _y + mtx[2][2] * _z
  end

  def render_x
    @x * (10 / (5 - @y)) * 170 + 640
  end

  def render_y
    @z * (10 / (5 - @y)) * 170 + 360
  end
end