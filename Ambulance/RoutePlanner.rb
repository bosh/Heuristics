class RoutePlanner
	attr_accessor :people, :hospitals, :ambulances, :score
	def initialize(people, hospitals, cluster_points) #TODO the last part!
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
				if available_people.size > 0
					people_urgencies = available_people.map{|p| p.urgency_to(a, time)}
					person_to_pick_up = available_people.delete_at(people_urgencies.index people_urgencies.max)
					a.add_order(Order.new(a.coords, person_to_pick_up))
				end

				hospital_distances = @hospitals.map{|h| a.distance_to h}
				closest_hospital = @hospitals[hospital_distances.index hospital_distances.min]

				if a.current_passengers.size == 4
					puts "returning home"
					a.add_order(Order.new(a.coords, closest_hospital))
				elsif a.current_passengers.size == 3 && people_urgencies.max < 5
					puts "returning home 3/non-urgent"
					a.add_order(Order.new(a.coords, closest_hospital))
				end

			end
			time = @ambulances.map(&:next_time_available).min
			available_people = @people.map{|person| person.available_at?(time) ? person : nil}.compact
			ambulances_to_order = @ambulances.map{|ambulance| ambulance.next_time_available <= time ? ambulance : nil}.compact
			if available_people.size == 0
				@ambulances.each do |amb|
					if amb.orders.last.action != :d
						hospital_distances = @hospitals.map{|h| amb.distance_to h}
						closest_hospital = @hospitals[hospital_distances.index hospital_distances.min]
						amb.add_order(Order.new(amb.coords, closest_hospital))
					end
				end
			end
		end
		@score = @people.count{|p| p.saved}
	end
end
