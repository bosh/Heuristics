class Intersection < Point
	attr_accessor :lines, :intersected
	def initialize(line_one, line_two) #Based on http://local.wasp.uwa.edu.au/~pbourke/geometry/lineline2d/
		@lines = [line_one, line_two]
		if line_one.slope == line_two.slope #Parallel
			intersected = false
			super(nil, nil)
		else
			intersected = true
			x1 = line_one.points[0].x
			x2 = line_one.points[1].x
			y1 = line_one.points[0].y
			y2 = line_one.points[1].y
			x3 = line_two.points[0].x
			x4 = line_two.points[1].x
			y3 = line_two.points[0].y
			y4 = line_two.points[1].y

			x_one = x2 - x1
			x_two = x3 - x4
			x_diff = x1 - x3

			y_one = y2 - y1
			y_two = y3 - y4
			y_diff = y1 - y3

			denom = ((y_two * x_one) - (x_two * y_one))
			if denom == 0
				puts "zero"
				super(nil, nil)
			else
				u_one = ((x_two*y_diff) - (y_two * x_diff)) / denom
				intersection_x = x1 + (u_one * x_one)
				intersection_y = y1 + (u_one * y_one)
				super(intersection_x, intersection_y)
			end
		end
	end
end