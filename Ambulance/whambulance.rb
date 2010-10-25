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
		@number = $person_count
		$person_count += 1
	end

	def to_s; [@number, @x, @y, @death].join ", " end
	def place_at(x, y); @x, @y = x, y end
	def coords; [x,y] end
	def distance_to(obj); (obj.x - @x).abs + (obj.y - @y).abs end
	def cluster_distance_to(obj); (obj.x - @x).abs + (obj.y - @y).abs end
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
	attr_accessor :x, :y, :orders, :start_hospital
	def initialize(hospital)
		@start_hospital = hospital
		@orders = []
	end

	def to_s; [@x, @y].join ", " end
	def place_at(coords); @x, @y = coords end
	def coords; [x,y] end
	def distance_to(obj); (obj.x - @x).abs + (obj.y - @y).abs end
end

class ClusterController
	attr_accessor :people, :hospitals, :cluster_distances

	def initialize(people, hospitals)
		@people = people.clone
		@hospitals = hospitals.clone
		place_randomly!
		cluster! #This should be repeatable so I could call cluster! 100 times and get a well clustered set
	end

	def place_randomly!
		person_hospital_distances = []
		@hospitals.each do |hospital| #This is the place randomly and do means method
			x = $bounds[:x][:min] + $width*rand()
			y = $bounds[:y][:min] + $height*rand()
			hospital.place_at(x, y)
			person_hospital_distances << []
			current_hospital_distances = person_hospital_distances.last
			@people.each{ |person| current_hospital_distances << person.cluster_distance_to(hospital) }
		end
		@cluster_distances = person_hospital_distances
	end

	def cluster!
	end
end

#########Program execution#############
$person_count = 0
$bounds = {	:x => {:min => 99, :max => 0},
			:y => {:min => 99, :max => 0},
			:death => {:min => 99, :max => 0}}
people = []
hospitals = []
mode = nil
File.readlines("ambulance_data.txt").each do |line|
	if line =~ /\A\W*\z/
		#donothing
	elsif line =~ /person/
		mode = :people
	elsif line =~ /hospital/
		mode = :hospitals
	else
		people		<< Person.new(line)		if mode == :people
		hospitals	<< Hospital.new(line)	if mode == :hospitals
	end
end

$width = $bounds[:x][:max] - $bounds[:x][:min]
$height = $bounds[:y][:max] - $bounds[:y][:min]
$deathClock = $bounds[:death][:max] - $bounds[:death][:min]

clusterer = ClusterController.new(people, hospitals)
