class Person
	attr_accessor :number, :x, :y, :death, :in_ambulance, :saved
	def initialize(str)
		data = str.split ","
		coords = (@x,@y = data[0].to_i, data[1].to_i)

		$bounds[:x][:min] = @x if @x < $bounds[:x][:min]
		$bounds[:x][:max] = @x if @x > $bounds[:x][:max]
		$bounds[:y][:min] = @x if @x < $bounds[:y][:min]
		$bounds[:y][:max] = @x if @x > $bounds[:y][:max]

		@death = data[2].to_i
		@number = $person_count
		@in_ambulance = nil
		@saved = false
		$person_count += 1
	end

	def to_s; [@number, @x, @y, @death].join ", " end
	def place_at(x, y); @x, @y = x, y end
	def coords; [x,y] end
	def distance_to(obj); (obj.x - @x).abs + (obj.y - @y).abs end
	def available_at?(time); time < @death && in_ambulance.nil? && !@saved end
	def save!(time) @saved = true if time <= @death end
	def cluster_distance_to(hospital)
		((hospital.x - @x).abs + (hospital.y - @y).abs) * (1 - (hospital.ambulance_count.to_f / 25))
	end
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
	def next_time_available; (@orders.empty? ? 1 : @orders.last.finishing_time + 1 ) end
end

class ClusterController
	attr_accessor :people, :hospitals, :cluster_distances, :best_cluster, :stable_clusters
	def initialize(people, hospitals)
		@people = people.clone
		@hospitals = hospitals.clone
		@stable_clusters = []
		start_clustering = Time.now
		until Time.now > start_clustering + $cluster_generation_time_limit
			last_cluster = nil
			new_cluster = nil
			place_randomly!
			until new_cluster && new_cluster == last_cluster || Time.now > start_clustering + $cluster_generation_time_limit #Can be set up when clusters can be compared for goodness of result meaningfully
				last_cluster = new_cluster
				new_cluster = cluster!
			end
			@stable_clusters << new_cluster
		end
		@best_cluster = select_best_cluster
	end

	def place_randomly!
		person_hospital_distances = []
		@hospitals.each do |hospital| #This is the place randomly and do means method
			x, y = generateRandomX, generateRandomY
			hospital.place_at(x, y)
			person_hospital_distances << []
			current_hospital_distances = person_hospital_distances.last
			@people.each{ |person| current_hospital_distances << person.cluster_distance_to(hospital) }
		end
		@cluster_distances = person_hospital_distances
	end

	def cluster!
		points = []
		calculate_cluster_distances!
		closest_hospitals = []
		@people.each_with_index do |person, i|
			distances_to_person = (0...@hospitals.length).map{|h| @cluster_distances[h][i]}
			closest_hospital = distances_to_person.index distances_to_person.min
			closest_hospitals[i] = @hospitals[closest_hospital]
		end
		@hospitals.each_with_index do |hospital, i|
			people_in_range = []
			closest_hospitals.each_with_index{|h, i| people_in_range << @people[i] if hospital == h}
			means = {}
			if people_in_range.empty?
				means[:x], means[:y] = generateRandomX, generateRandomY
			else
				means[:x] = people_in_range.inject(0){|sum, p| sum += p.x }.to_f / people_in_range.size #Could change to some special weighting of points
				means[:y] = people_in_range.inject(0){|sum, p| sum += p.y }.to_f / people_in_range.size
			end
			hospital.place_at(means[:x].round, means[:y].round)
			#could add smarter placement that chooses a slightly worse spot if it drops directly on a person
			points << [means[:x].round, means[:y].round]
		end
		points
	end

	def calculate_cluster_distances!
		person_hospital_distances = []
		@hospitals.each do |hospital| #This is the place randomly and do means method
			x,y = hospital.coords
			person_hospital_distances << []
			current_hospital_distances = person_hospital_distances.last
			@people.each{ |person| current_hospital_distances << person.cluster_distance_to(hospital) }
		end
		@cluster_distances = person_hospital_distances
	end

	def select_best_cluster #TODO (placeholder)
		@stable_clusters[(@stable_clusters.length * rand()).floor]
	end
end

class RoutePlanner
	attr_accessor :people, :hospitals, :ambulances
	def initialize(people, hospitals, cluster_points) #TODO the last part!
		@hospitals = hospitals
		@people = people
		@ambulances = []
		@hospitals.each_with_index do |hospital, i|
			hospital.place_at(i[0], i[1])
			person_at_hospital = @people.map{|p| p.coords == hospital.coords}.index(true)
			@people[person_at_hospital].save! if person_at_hospital #Save anyone placed on top of
			hospital.ambulances.each do |ambulance|
				ambulance.place_at(hospital.coords)
				@ambulances << ambulance
			end
		end

		time = 0
		available_people = []
		@people.each{|person| available_people << person if person.available_at?(time)}
		until available_people.empty?

			time = @ambulances.map(&:next_time_available).min
			available_people = []
			@people.each{|person| available_people << person if person.available_at?(time)}
		end
		#for every ambulance in every hospital find the closest savable very needy person
		#	for every closer and slightly less needy person,
		#		see if they can fit in the route before the current person
		#		see if they can be placed after the first person before the next dropoff
		#			(if the detour distance and distance to the new endpoint - the distance that was interrupted is not too much worse and causes no current passenger deaths, take it)
		#	for every further and slightly less needy person,
		#		do similar to the above loop
		# NOTE: probably run individual pickups all at once, so everyone has a first person before seconds are selected
		# NOTE: to save 300 people at 3 people average a trip, that's 100 trips. at 5*8 expected ambulances, that's 2.5 sets of 3, ie 7-8 total people an ambulance for total coverage
		# NOTE: This all uses normal distances, not weighed as was used to cluster.
	end
end

def generateRandomX; $bounds[:x][:min] + $width*rand() end
def generateRandomY; $bounds[:y][:min] + $width*rand() end

#########Program execution#############
$cluster_generation_time_limit = 5
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
route_planner = RoutePlanner.new(people, hospitals, clusterer.best_cluster)