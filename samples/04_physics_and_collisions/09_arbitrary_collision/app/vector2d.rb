class Vector2d
    attr_accessor :x, :y
  
    def initialize x=0, y=0
      @x=x
      @y=y
    end
  
    #returns a vector multiplied by scalar x
    #x [float] scalar
    def mult x
      r = Vector2d.new(0,0)
      r.x=@x*x
      r.y=@y*x
      r
    end
  
    # vect [Vector2d] vector to copy
    def copy vect
      Vector2d.new(@x, @y)
    end
  
    #returns a new vector equivalent to this+vect
    #vect [Vector2d] vector to add to self
    def add vect
      Vector2d.new(@x+vect.x,@y+vect.y)
    end
  
    #returns a new vector equivalent to this-vect
    #vect [Vector2d] vector to subtract to self
    def sub vect
      Vector2d.new(@x-vect.c, @y-vect.y)
    end
  
    #return the magnitude of the vector
    def mag
      ((@x**2)+(@y**2))**0.5
    end
  
    #returns a new normalize version of the vector
    def normalize
      Vector2d.new(@x/mag, @y/mag)
    end
  
    #TODO delet?
    def distABS vect
      (((vect.x-@x)**2+(vect.y-@y)**2)**0.5).abs()
    end
  end