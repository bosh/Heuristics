require 'Core'

def generateRandomX; $bounds[:x][:min] + $width*rand() end
def generateRandomY; $bounds[:y][:min] + $width*rand() end
def reset!
	$people.each{|p| p.reset! }
	$hospitals.each{|p| p.reset! }
end

#########Program execution#############
$start_time = Time.now
$program_run_limit = 118
$cluster_generation_time_limit = 20
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
clusterer.stable_clusters.each do |cluster|
	break if Time.now - $start_time > $program_run_limit
	people.each{|p| p.reset!}
	hospitals.each{|h| h.reset!}
	route_planner = RoutePlanner.new(people, hospitals, cluster)
	puts route_planner.score
	if route_planner.score > score
		score = route_planner.score
		best = route_planner
	end
end
puts "Best score: #{score}"
