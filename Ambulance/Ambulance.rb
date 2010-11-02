class Ambulance
	attr_accessor :x, :y, :orders, :start_hospital, :current_passengers
	def initialize(hospital)
		@start_hospital = hospital
		@orders = []
		@current_passengers = []
	end

	def to_s; "Ambulance: " + coords.join(", ") end
	def place_at(coords); @x, @y = coords end
	def coords; [@x,@y] end
	def distance_to(obj); (obj.x - @x).abs + (obj.y - @y).abs end

	def reset!
		place_at(@start_hospital.coords)
		@orders = []
		@current_passengers = []
	end
	
	def closest_hospital(hospitals)
		hospital_distances = hospitals.map{|h| distance_to h}
		hospitals[hospital_distances.index hospital_distances.min]
	end

	def pick_up!(person)
		@current_passengers << person
		person.in_ambulance = self
	end

	def soonest_death(time)
		times = [999]
		times += @current_passengers.map(&:death).reject{|t| t <= time}
		times.min
	end

	def add_order(order)
		puts "ERROR. IMPOSSIBLE" if coords != order.start_point
		place_at(order.end_point)
		if order.action == :p
			pick_up! order.object
		elsif order.action == :d
			drop_off!
		end
		@orders << order
	end

	def drop_off!
		@current_passengers.each{|p| p.save!(next_time_available - 1)}
		@current_passengers = []
	end

	def must_return_to_hospital_by_time
		@current_passengers.empty? ? $bounds[:death][:max] : @current_passengers.map(&:death).min
	end

	def next_time_available
		(@orders.empty? ? 1 : @orders.inject(0){|sum, o| sum += o.time_taken} + 1 )
	end

	def to_validator(i)
		text = ""
		name = "Ambulance #{i} "
		@orders.each{|o| text << name << o.to_validator << "\n"}
		text
	end
end
