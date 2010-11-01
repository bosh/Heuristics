class Person
	attr_accessor :number, :x, :y, :death, :in_ambulance, :saved
	def initialize(str)
		data = str.split ","
		coords = (@x,@y = data[0].to_i, data[1].to_i)
		@death = data[2].to_i

		$bounds[:x][:min] = @x if @x < $bounds[:x][:min]
		$bounds[:x][:max] = @x if @x > $bounds[:x][:max]
		$bounds[:y][:min] = @x if @x < $bounds[:y][:min]
		$bounds[:y][:max] = @x if @x > $bounds[:y][:max]
		$bounds[:death][:min] = @death if @death < $bounds[:death][:min]
		$bounds[:death][:max] = @death if @death > $bounds[:death][:max]

		reset!
		@number = $person_count
		$person_count += 1
	end

	def reset!
		@in_ambulance = nil
		@saved = false
	end

	def to_s; [@number, @x, @y, @death].join ", " end
	def place_at(x, y); @x, @y = x, y end
	def coords; [x,y] end
	def distance_to(obj); (obj.x - @x).abs + (obj.y - @y).abs end
	def available_at?(time); time < @death && in_ambulance.nil? && !@saved end
	def save!(time)
		@saved = true if time <= @death
		@in_ambulance = nil
	end

	def cluster_distance_to(hospital)
		((hospital.x - @x).abs + (hospital.y - @y).abs) * (1 - (hospital.ambulance_count.to_f / 25))
	end

	def urgency_to(ambulance, time)
		time_left = @death - time
		if time_left > $deathClock / 2
			$deathClock / time_left
		elsif time_left < 1.3*distance_to(ambulance)
			-1
		else
			(distance_to(ambulance)**(0.5)) / time_left
		end
	end
end
