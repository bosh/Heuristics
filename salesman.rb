# require 'rubygems'
# gem 'algorithms', '= 0.3.0'

class FullPath
	attr_accessor :points, :paths, :total_solution_distance
	def initialize
		@points = PointSet.new
		@paths = PathSet.new(@points)
		@total_solution_distance = @paths.calculate_distance
	end
	def to_s
		"Total Distance: #{@total_solution_distance}"#\nPaths:\n#{@paths}"
	end
end

class PointSet
	attr_accessor :points_by_x, :points_by_y, :points_by_z, :points
	def initialize
		@points = []
		File.open("salesman_data.txt","r") do |f|
			f.each_line{|line| line = line.split(" "); @points[line[0].to_i] = Point.new(line[0].to_i, line[1].to_i, line[2].to_i, line[3].to_i) }
		end
		data = @points.reject(&:nil?).map(&:to_data)
		@points_by_x = data.sort_by{|(num,x,y,z)| [x, y, z, num]}
		@points_by_y = data.sort_by{|(num,x,y,z)| [y, x, z, num]}
		@points_by_z = data.sort_by{|(num,x,y,z)| [z, x, y, num]}
	end
end

class PathSet
	attr_accessor :paths
	def initialize(pointset)
		points = pointset.points
		(2...points.length).each {|i| $paths[i] ||= []; (1...i).each {|j| $paths[j] ||= []; $paths[i][j] = $paths[j][i] = points[i].distance_to(points[j])}}
		@paths = create_mst(pointset)
		optimize! until time_up?
	end
	def create_mst(pointset)
		points = pointset.points
		inf = 0**-1
		distances = Array.new(points.length, inf)
		visited = Array.new(points.length, false)
		current = points[1]
		distances[current.number] = 0
		while current #visited.reject{|val| val == nil || val == true}.size > 0
			points.each do |neighbor|
				next if neighbor.nil? || visited[neighbor.number] || current == neighbor
				distances[neighbor.number] = [distances[neighbor.number], $paths[current.number][neighbor.number]].min
			end
			visited[current.number] = true
			min = inf
			index = 0
			distances.each_with_index do |d, i|
				next if d == nil || visited[i]
				min = [d, min].min
				index = i if min == d
			end
			current = points[index]
		end
		distances[1..-1]
	end
	def optimize!
		#HNNNNG!
	end
	def calculate_distance
		@paths.inject{|sum,path| sum += path}#path.distance}
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
		$paths[@uid.first][@uid.last]
	end
	def connects_to?(point)
		@endpoints.include? point
	end
end

def time_up?; Time.now - $start_time > $seconds_to_run end

$start_time = Time.now
$seconds_to_run = 4
$paths = [] # Distance calculation store
results = FullPath.new
puts "\t\t**Algorithm Stopped**\nTime Elapsed: #{Time.now - $start_time} seconds\n"
puts results
#save out the results to a text file