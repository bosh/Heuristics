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
