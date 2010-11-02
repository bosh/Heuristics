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
