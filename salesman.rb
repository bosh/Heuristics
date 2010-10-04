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
		File.open("salesman_data.txt","r") do |f|
			f.each_line{|line| line = line.split(" "); @points[line[0].to_i] = Point.new(line[0].to_i, line[1].to_i, line[2].to_i, line[3].to_i) }
		end
		data = @points.map(&:to_data)
		# @points_by_x = data.sort_by{|(num,x,y,z)| [x, y, z, num]}
		# @points_by_y = data.sort_by{|(num,x,y,z)| [y, x, z, num]}
		# @points_by_z = data.sort_by{|(num,x,y,z)| [z, x, y, num]}
	end
end

class PathSet
	attr_accessor :paths
	def initialize(points)
		@paths = create_mst(points)
		optimize! until time_up?
	end
	def create_mst(points)
		connections = []
		#djikstras here into connections
		connections
	end
	def optimize!
		#HNNNNG!
	end
	def to_s
		@paths.join(",")
	end
end

class Point
	attr_accessor :number, :x, :y, :z
	def initialize(no, x, y, z)
		@number = no
		@x = x
		@y = y
		@z = z
	end
	def to_data
		[@number, @x, @y, @z]
	end
	def distance_to(point) #Calulates the distance to another point. Could use lookup
		coords = [self, point].map{|p| [p.x, p.y, p.z]}
		sum = 0
		(0..2).each{|i| sum += (coords[0][i] - coords[1][i])**2 }
		sum**0.5
	end
end

class Path
	attr_accessor :endpoints, :distance, :uid, :xuid
	def initialize(point1, point2)
		@endpoints = [point1, point2]
		@uid = @endpoints.map(&:number)
		@xuid = @uid.reverse
		@distance = find_distance
	end
	def find_distance #Calculates the distance and saves it to a lookup table
		$paths[@uid.first] ||= []
		$paths[@xuid.first] ||= []
		$paths[@uid.first][@uid.last] ||= @endpoints.first.distance_to @endpoints.last
		$paths[@xuid.first][@xuid.last] ||= @endpoints.first.distance_to @endpoints.last
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
$paths = [] # Distance calculation store
results = FullPath.new
puts "\t\t**Algorithm Stopped**\nTime Elapsed: #{Time.now - $start_time} seconds\n"
puts results
#save out the results to a text file