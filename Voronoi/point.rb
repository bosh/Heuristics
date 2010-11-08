class Point
	attr_accessor :x, :y
	def initialize(x,y)
		@x = x
		@y = y
	end

	def distance_to(point)
		((@x - point.x)**2 + (@y - point.y)**2)**(0.5)
	end

	def midpoint_to(point)
		Point.new((@x + point.x).to_f / 2.0, (@y + point.y).to_f / 2.0)
	end

	def slope_to(point)
		(point.y - @y).to_f / (point.x - @x).to_f
	end

	def line_to(point)
		Line.new(self, point)
	end
end