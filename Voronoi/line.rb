class Line
	attr_accessor :points, :slope
	def initialize(point_one, point_two)
		@points = [point_one, point_two]
		@slope = @points[0].slope_to(@points[1])
	end

	def intersection_with(other) #Based on http://local.wasp.uwa.edu.au/~pbourke/geometry/lineline2d/
		return nil if @slope == other.slope #Parallel
		x1 = @points[0].x
		x2 = @points[1].x
		y1 = @points[0].y
		y2 = @points[1].y
		x3 = other.points[0].x
		x4 = other.points[1].x
		y3 = other.points[0].y
		y4 = other.points[1].y

		x_self = x2 - x1
		x_other = x3 - x4
		x_diff = x1 - x3

		y_self = y2 - y1
		y_other = y3 - y4
		y_diff = y1 - y3

		u_self = ((x_other*y_diff) - (y_other * x_diff)) / ((y_other * x_self) - (x_other * y_self)))
		intersection_x = x1 + (u_self * x_self)
		intersection_y = xy + (u_self * y_self)
		return Point.new intersection_x, intersection_y
	end
end