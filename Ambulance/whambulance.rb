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

	def to_validator
		"#{@number} (#{@x},#{@y},#{@death})"
	end

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

class RoutePlanner
	attr_accessor :people, :hospitals, :ambulances, :score
	def initialize(people, hospitals, cluster_points)
		@hospitals = hospitals
		@people = people
		@ambulances = []
		@hospitals.each_with_index do |hospital, i|
			hospital.place_at(cluster_points[i][0], cluster_points[i][1])
			person_at_hospital = @people.map{|p| p.coords == hospital.coords}.index(true)
			@people[person_at_hospital].save!(0) if person_at_hospital #Save anyone placed on top of
			hospital.ambulances.each do |ambulance|
				ambulance.place_at(hospital.coords)
				@ambulances << ambulance
			end
		end

		time = 1
		available_people = @people.map{|person| person.available_at?(time) ? person : nil}.compact
		ambulances_to_order = @ambulances.map{|ambulance| ambulance.next_time_available <= time ? ambulance : nil}.compact
		until available_people.empty?
			ambulances_to_order.each do |a|
				closest = a.closest_hospital(@hospitals)

				if available_people.size > 0
					people_urgencies = available_people.map{|p| p.urgency_to(a, time)}
					person_to_pick_up = available_people[people_urgencies.index people_urgencies.max]
					if a.soonest_death(time) > time + 1 + a.distance_to(closest) && a.soonest_death(time) < time + 2 + a.distance_to(closest) + closest.distance_to(person_to_pick_up)
						a.add_order(Order.new(a.coords, closest))
					else
						available_people.delete(person_to_pick_up)
						a.add_order(Order.new(a.coords, person_to_pick_up))
						a.add_order(Order.new(a.coords, a.closest_hospital(@hospitals))) if a.soonest_death(time) > time + 2 + a.distance_to(closest) + a.distance_to(a.closest_hospital(@hospitals))
					end
				end
				if a.current_passengers.size == 4
					# puts "returning home"
					a.add_order(Order.new(a.coords, a.closest_hospital(@hospitals)))
				elsif a.current_passengers.size == 3 && people_urgencies.max < 5 && a.orders.last.object.class != Hospital
					# puts "returning home 3/non-urgent"
					a.add_order(Order.new(a.coords, a.closest_hospital(@hospitals)))
				end
			end
			time = @ambulances.map(&:next_time_available).min
			available_people = @people.map{|person| person.available_at?(time) ? person : nil}.compact
			ambulances_to_order = @ambulances.map{|ambulance| ambulance.next_time_available <= time ? ambulance : nil}.compact
			if available_people.size == 0
				@ambulances.each do |amb|
					amb.add_order(Order.new(amb.coords, amb.closest_hospital(@hospitals))) if amb.orders.last.action != :d
				end
			end
		end
		@score = @people.count{|p| p.saved}
	end

	def to_validator
		text = "Hospitals"
		@hospitals.each_with_index{|h, i| text << " #{i} #{h.to_validator}" }
		text << "\n"
		@ambulances.each_with_index{|a, i| text << a.to_validator(i)}
		text
	end
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

class Order
	attr_accessor :start_point, :end_point, :time_taken, :action, :object #Time includes time to pick up
	def initialize(start_point, object_at_end_point)
		@start_point = start_point
		@end_point = object_at_end_point.coords
		@object = object_at_end_point
		if object_at_end_point.class == Hospital
			@action = :d
		elsif object_at_end_point.class == Person
			@action = :p
		end
		@time_taken = calculate_time_taken
	end

	def calculate_time_taken
		(start_point[0] - end_point[0]).abs + (start_point[1] - end_point[1]).abs + 1
	end

	def to_s
		"(#{@end_point.join ","})   \t#{@action.to_s.upcase}\tS:#{@time_taken}"
	end

	def to_validator
		object.to_validator
	end
end

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

def generateRandomX; $bounds[:x][:min] + $width*rand() end
def generateRandomY; $bounds[:y][:min] + $width*rand() end
def reset!
	$people.each{|p| p.reset! }
	$hospitals.each{|p| p.reset! }
end

#########Program execution#############
$start_time = Time.now
$program_run_limit = 118
$cluster_generation_time_limit = 66
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
score = 0
best = nil
validator_text = ""
clusterer.stable_clusters.each do |cluster|
	break if Time.now - $start_time > $program_run_limit
	people.each{|p| p.reset!}
	hospitals.each{|h| h.reset!}
	route = RoutePlanner.new(people, hospitals, cluster)
	print "#{route.score}\t"
	if route.score > score
		score = route.score
		best = route
		validator_text = route.to_validator
	end
end
puts "\nBest score: #{score}"
puts "Time: #{Time.now - $start_time}"
File.new("to_validate.txt", "w").puts validator_text
