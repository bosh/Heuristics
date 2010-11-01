class Hospital
	attr_accessor :x, :y, :ambulances, :ambulance_count
	def initialize(line)
		@ambulances = []
		@ambulance_count = line.to_i
		@ambulance_count.times {|i| @ambulances << Ambulance.new(self)}
	end

	def reset!
		@ambulances.each{|a| a.reset!}
	end

	def place_at(x,y)
		@x, @y = x, y
		@ambulances.each{|ambulance| ambulance.place_at(@x, @y)}
	end

	def to_validator
		"(#{coords.join ","})"
	end

	def to_s; [ @x || "Unplaced", @y || "Unplaced", @ambulance_count ].join ", " end
	def place_at(x, y); @x, @y = x, y end
	def coords; [x,y] end
	def distance_to(obj); (obj.x - @x).abs + (obj.y - @y).abs end
end
