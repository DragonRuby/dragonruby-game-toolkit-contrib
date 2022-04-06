class ModelingApi
  attr :matricies

  def initialize
    @matricies = []
  end

  def scale x: 1, y: 1, z: 1
    @matricies << scale_matrix(x: x, y: y, z: z)
    if block_given?
      yield
      @matricies << scale_matrix(x: -x, y: -y, z: -z)
    end
  end

  def translate x: 0, y: 0, z: 0
    @matricies << translate_matrix(x: x, y: y, z: z)
    if block_given?
      yield
      @matricies << translate_matrix(x: -x, y: -y, z: -z)
    end
  end

  def rotate_x x
    @matricies << rotate_x_matrix(x)
    if block_given?
      yield
      @matricies << rotate_x_matrix(-x)
    end
  end

  def rotate_y y
    @matricies << rotate_y_matrix(y)
    if block_given?
      yield
      @matricies << rotate_y_matrix(-y)
    end
  end

  def rotate_z z
    @matricies << rotate_z_matrix(z)
    if block_given?
      yield
      @matricies << rotate_z_matrix(-z)
    end
  end

  def scale_matrix x:, y:, z:;
    mat4 x, 0, 0, 0,
         0, y, 0, 0,
         0, 0, z, 0,
         0, 0, 0, 1
  end

  def translate_matrix x:, y:, z:;
    mat4 1, 0, 0, x,
         0, 1, 0, y,
         0, 0, 1, z,
         0, 0, 0, 1
  end

  def rotate_y_matrix angle_d
    cos_t = Math.cos angle_d.to_radians
    sin_t = Math.sin angle_d.to_radians
    (mat4  cos_t,  0, sin_t, 0,
           0,      1, 0,     0,
           -sin_t, 0, cos_t, 0,
           0,      0, 0,     1)
  end

  def rotate_z_matrix angle_d
    cos_t = Math.cos angle_d.to_radians
    sin_t = Math.sin angle_d.to_radians
    (mat4 cos_t, -sin_t, 0, 0,
          sin_t,  cos_t, 0, 0,
          0,      0,     1, 0,
          0,      0,     0, 1)
  end

  def rotate_x_matrix angle_d
    cos_t = Math.cos angle_d.to_radians
    sin_t = Math.sin angle_d.to_radians
    (mat4  1,     0,      0, 0,
           0, cos_t, -sin_t, 0,
           0, sin_t,  cos_t, 0,
           0,     0,      0, 1)
  end

  def __mul_triangles__ model, *mul_def
    model.map do |vecs|
      vecs.map do |vec|
        mul vec,
            *mul_def
      end
    end
  end
end

def square &block
  square_verticies = [
    [vec4(0, 0, 0, 1),   vec4(1.0, 0, 0, 1),   vec4(0, 1.0, 0, 1)],
    [vec4(1.0, 0, 0, 1), vec4(1.0, 1.0, 0, 1), vec4(0, 1.0, 0, 1)]
  ]

  m = ModelingApi.new
  m.instance_eval &block if block
  m.__mul_triangles__ square_verticies, *m.matricies
end
