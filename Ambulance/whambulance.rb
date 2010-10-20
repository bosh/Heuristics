class Person
	attr_accessor :number, :x, :y, :death

	def initialize(str)
		data = str.split ","
		@x = data[0]
		@y = data[1]
		@death = data[2]
		@number = $people_count
		$people_count += 1
	end

	def to_s; [@number, @x, @y, @death].join ",\t" end
	def place_at(x, y); @x, @y = x, y end
	def coords; [x,y] end
	def distance_to(obj); (obj.x - @x).abs + (obj.y - @y).abs end
end

def Hospital
	attr_accessor :x, :y, :ambulances, :ambulance_count

	def initialize(count)
		@ambulances = []
		@ambulance_count = count.to_i
		count.times {|i| @ambulances << Ambulance.new}
	end

	def place_at(x,y)
		@x, @y = x, y
		@ambulances.each{|ambulance| ambulance.place_at(@x, @y)}
	end

	def to_s; [@x||"Unplaced", @y||"Unplaced", @ambulance_count].join ",\t" end
	def place_at(x, y); @x, @y = x, y end
	def coords; [x,y] end
	def distance_to(obj); (obj.x - @x).abs + (obj.y - @y).abs end
end

def Ambulance
	attr_accessor :x, :y, :orders

	def initialize()

	end

	def to_s; [@x, @y].join ",\t" end
	def place_at(x, y); @x, @y = x, y end
	def coords; [x,y] end
	def distance_to(obj); (obj.x - @x).abs + (obj.y - @y).abs end
end

#########Program execution#############

$people = []
$people_count = 0
$hospitals = []
mode = nil
File.readlines("ambulance_data.txt").each do |line|
	if line =~ /person/
		mode = "people"
	elsif line =~ /hospital/
		mode = "hospitals"
	else
		people		<< Person.new(line)		if !line.blank? && mode == "people"
		hospitals	<< Hospital.new(line)	if !line.blank? && mode == "hospitals"
	end
end
