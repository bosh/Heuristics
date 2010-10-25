class Person
	attr_accessor :number, :x, :y, :death

	def initialize(str)
		data = str.split ","
		coords = (@x,@y = data[0].to_i, data[1].to_i)

		$bounds[:x][:min] = @x if @x < $bounds[:x][:min]
		$bounds[:x][:max] = @x if @x > $bounds[:x][:max]
		$bounds[:y][:min] = @x if @x < $bounds[:y][:min]
		$bounds[:y][:max] = @x if @x > $bounds[:y][:max]

		@death = data[2].to_i
		@number = $people.count
	end

	def to_s; [@number, @x, @y, @death].join ", " end
	def place_at(x, y); @x, @y = x, y end
	def coords; [x,y] end
	def distance_to(obj); (obj.x - @x).abs + (obj.y - @y).abs end
end

class Hospital
	attr_accessor :x, :y, :ambulances, :ambulance_count

	def initialize(line)
		@ambulances = []
		@ambulance_count = line.to_i
		@ambulance_count.times {|i| @ambulances << Ambulance.new(self)}
	end

	def place_at(x,y)
		@x, @y = x, y
		@ambulances.each{|ambulance| ambulance.place_at(@x, @y)}
	end

	def to_s; [ @x || "Unplaced", @y || "Unplaced", @ambulance_count ].join ", " end
	def place_at(x, y); @x, @y = x, y end
	def coords; [x,y] end
	def distance_to(obj); (obj.x - @x).abs + (obj.y - @y).abs end
end

class Ambulance
	attr_accessor :x, :y, :orders
	def initialize(hospital)
		place_at(hospital.coords)
		@orders = []
	end

	def to_s; [@x, @y].join ", " end
	def place_at(coords); @x, @y = coords end
	def coords; [x,y] end
	def distance_to(obj); (obj.x - @x).abs + (obj.y - @y).abs end
end

#########Program execution#############
$bounds = {	:x => {:min => 99, :max => 0},
			:y => {:min => 99, :max => 0}}
$people = []
$hospitals = []
mode = nil
File.readlines("ambulance_data.txt").each do |line|
	if line =~ /\A\W*\z/
		#donothing
	elsif line =~ /person/
		mode = "people"
	elsif line =~ /hospital/
		mode = "hospitals"
	else
		$people		<< Person.new(line)		if mode == "people"
		$hospitals	<< Hospital.new(line)	if mode == "hospitals"
	end
end

puts $people.map(&:to_s).join "\n"
puts $hospitals.map(&:to_s).join "\n"
