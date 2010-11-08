class Line
	attr_accessor :points, :slope
	def initialize(point_one, point_two)
		@points = [point_one, point_two]
		@slope = @points[0].slope_to(@points[1])
	end
end