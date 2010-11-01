class Order
	attr_accessor :start_point, :end_point, :time_taken, :action, :object #Time includes time to pick up
	def initialize(start_point, object_at_end_point)
		@start_point = start_point
		@end_point = object_at_end_point.coords
		@object = object_at_end_point
		if object_at_end_point.class == "Hospital"
			@action = :d
		elsif object_at_end_point.class == "Person"
			@action = :p
		end
		@time_taken = calculate_time_taken
	end

	def calculate_time_taken
		(start_point[0] - end_point[0]).abs + (start_point[1] - end_point[1]).abs + 1
	end
end
