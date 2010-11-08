class Bisector < Line
	attr_accessor :midpoint, :slope
	def initialize(point_one, point_two)
		@slope = ( -1.0 ) / point_one.slope_to(point_two)
		@midpoint = point_one.midpoint_to(point_two)
		@points = [@midpoint, second_point]
	end

	def second_point
		Point.new @midpoint.x + 1, @midpoint.y + @slope
	end
end