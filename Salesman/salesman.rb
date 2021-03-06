# require 'rubygems'
# gem 'algorithms', '= 0.3.0'

class FullPath
	attr_accessor :points, :paths, :total_solution_distance
	def initialize
		@points = PointSet.new
		@paths = PathSet.new(@points)
		@total_solution_distance = @paths.calculate_distance
	end
	def to_s; "Total Distance: #{@total_solution_distance}" end #\nPaths:\n#{@paths}"
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
		preoptimize!
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
		generate_paths(points, distances)
	end
	def generate_paths(points, distances)
		pointers = []
		(2...distances.length).each{|i| pointers[i] = $paths[i].index(distances[i])}
		paths = []
		pointers.each_with_index {|p, i| paths << Path.new(points[p], points[i]) if p && i}
		paths
	end
	def preoptimize! #HNNNNG!
		counts = Array.new(1001, 0) #lol hardcoded
		endpoints = @paths.map{|path| path.endpoints.map{|point| point.number}}.flatten
		endpoints.each{|e| counts[e] += 1}
		until counts.reject{|c| c%2 == 0}.size > 0 do
			to_add = []
			#make mst of odd points
			#add all those paths 
			# to_add.each{|(one,two)| @paths << Path.new[]} # NEEDS ACCESS TO POINTS
			####Determine reentry
			endpoints = @paths.map{|path| path.endpoints.map{|point| point.number}}.flatten
			counts = Array.new(1001, 0) #lol hardcoded
			endpoints.each{|e| counts[e] += 1}
		end
	end
	def optimize!
		#find a node with more than two connectors
		#take all combinations of reductions and use the best

		#find a segment that is close to another point (requires line calculation and distance to point finding)
		#delete the segment and join the endpoints to the close point. attempt to run the optimizer
		#mark as checked if it goes back to where it was
	end
	def calculate_distance
		sum = 0
		@paths.each{|path| sum += path.distance}
		sum
	end
	def to_s; @paths.join(", ") end
end

class Point
	attr_accessor :number, :x, :y, :z
	def initialize(no, x, y, z)
		@number = no
		@x = x
		@y = y
		@z = z
	end
	def to_s; "<#{to_data.join ", "}>\t" end
	def to_data; [@number, @x, @y, @z] end
	def distance_to(point) #Calulates the distance to another point. Could use lookup
		coords = [self, point].map{|p| [p.x, p.y, p.z]}
		(0..2).inject{|val, i| val += (coords[0][i] - coords[1][i])**2}**0.5
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
	def find_distance; $paths[@uid.first][@uid.last] end
	def connects_to?(point); @endpoints.include? point end
end

def time_up?; Time.now - $start_time > $seconds_to_run end

$start_time = Time.now
$seconds_to_run = 4
$paths = [] # Distance calculation store
results = FullPath.new
puts "\t\t**Algorithm Stopped**\nTime Elapsed: #{Time.now - $start_time} seconds\n"
puts results
