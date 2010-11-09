class Point
	attr_accessor :x, :y
	def initialize(x,y)
		@x = x
		@y = y
	end

	def distance_to(point)
		return 9999 if @x == nil || @y == nil || point.x == nil || point.y || nil
		((@x - point.x)**2 + (@y - point.y)**2)**(0.5)
	end

	def midpoint_to(point)
		Point.new((@x + point.x).to_f / 2.0, (@y + point.y).to_f / 2.0)
	end

	def slope_to(p)
		rise = (p.y - @y).to_f
		run = (p.x - @x).to_f
		rise/run
	end

	def line_to(point)
		Line.new(self, point)
	end
end