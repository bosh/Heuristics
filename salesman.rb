class FullPath
	attr_accessor :points, :paths, :total_solution_distance
	def intialize
		@points = PointSet.new
		@paths = PathSet.new(@points)
		@total_solution_distance = @paths.calculate_distance
	end
	def to_s
		"Total Distance: #{@total_solution_distance}\nPaths:\n#{@paths}"
	end
end

class PointSet
	attr_accessor :points_by_x, :points_by_y, :points_by_z, :points
	def initialize
		@points = {}
		#read in all points into :points
		@points_by_x = generate_points_by_x
		@points_by_y = generate_points_by_y
		@points_by_z = generate_points_by_z
	end
end

class PathSet
	attr_accessor :paths
	def initialize(points)
		@paths = create_mst(points)
		@optimize until time_up?
	end
	def create_mst(points)
		@paths = {}
		#djikstras here
	end
	def to_s
		@paths.join(",")
	end
end

class Point
	attr_accessor :number, :x, :y, :z
	def initialize(no, x, y, z)
		@number = number
		@x = x
		@y = y
		@z = z
	end
	def distance_to(point) #Calulates the distance to another point. Could use lookup
		coords = [self, point].map{|p| [p.x, p.y, p.z]}
		sum = 0
		(0..2).each{|i| sum += (coords[0][i] - coords[1][i])**2 }
		sum**0.5
	end
end

class Path
	attr_accessor :endpoints, :distance, :uid
	def initialize(point1, point2)
		@endpoints = [point1, point2]
		@uid = "#{@endpoints.sort(&:number).map(&:number).join(',')}" #may want to generate two uids and save both...
		@distance = find_distance
	end
	def find_distance #Calculates the distance and saves it to a lookup table
		$paths[@uid] ||= @endpoints.first.distance_to @endpoints.last #may find it useful to generate both uids and save into both
	end
	def connects_to?(point)
		@endpoints.include? point
	end
end

def time_up?
	Time.now - $start_time > $seconds_to_run
end

$start_time = Time.now
$seconds_to_run = 10
$paths = {}
results = FullPath.new
puts "\t\t**Algorithm Stopped**\nTime Elapsed: #{Time.now - $start_time} seconds\n"
puts results
#save out the results to a text file