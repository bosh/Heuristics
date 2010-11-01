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
