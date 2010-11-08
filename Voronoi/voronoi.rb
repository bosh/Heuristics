# Voronoi problem, client app

class Point
	attr_accessor :owner, :x, :y, :bisectors
	def initialize(owner, x, y, game)
		@owner = owner
		@x = x
		@y = y
		@game = game
		@bisectors = @game.points.map{|p| Bisector.new(self, p)}
	end

	def distance_to(point)
		((@x - point.x)**2 + (@y - point.y)**2)**(0.5)
	end
	
	def midpoint_with(point)
		{:x => (@x + point.x)*1.0/2.0, :y => (@y + point.y)*1.0/2.0}
	end

	def slope_with(point)
		(point.y - @y)*1.0 / (point.x - @x)
	end

	def polygon
		@bisectors.map{|b| @bisectors.map{|o| b.intersection_with(o)}}
	end
end

class Polygon
	attr_accessor :lines, :vertices
	def initialize(lines)
		@lines = lines

		@vertices = []
	end

	def contains?(point)

	end
end

class Bisector
	attr_accessor :bisected_points, :midpoint, :slope, :x1, :x2, :y1, :y2
	def initialize(point_one, point_two)
		@bisected_points = [point_one, point_two]
		@midpoint = point_one.midpoint_with(point_two)
		@slope = -1.0 / point_one.slope_with(point_two)
		@x1 = @midpoint[:x]
		@y1 = @midpoint[:y]
		@x2 = @x1 + 1
		@y2 = @y1 + @slope
	end

	def intersection_with(other) #Based on http://local.wasp.uwa.edu.au/~pbourke/geometry/lineline2d/
		return nil if @slope == other.slope #Parallel
		x_self = @x2 - @x1
		x_other = other.x1 - other.x2
		x_diff = @x1 - other.x1

		y_self = @y2 - @y1
		y_other = other.y1 - other.y2
		y_diff = @y1 - other.y1

		u_self = ((x_other*y_diff) - (y_other * x_diff)) / ((y_other * x_self) - (x_other * y_self)))
		intersection_x = @x1 + (u_self * x_self)
		intersection_y = @xy + (u_self * y_self)
		return {:x => intersection_x, :y => intersection[:y]}
	end
end

class Player
	attr_accessor :number, :game
	def initialize(n, game)
		@number = n
		@game = game
	end

	def points
		@game.points.select{|p| p.owner == self}
	end
end

class Voronoi
	attr_accessor :points, :dimensions, :players, :current_player
	def initialize
		@dimensions = $dimensions
		@points = []
		connect
	end

	def connect
		n = @player_number || 999 #TODO
		@current_player = @players[n] #TODO
		#TODO socket related #Assigns number told by connection
	end

	def first_turn?
		@points.empty?
	end

	def add_point(point)
		@points.each do |p|
			p.bisectors << p.bisector_with(point)
		end
		@points << point
	end

	def simulate_move(coord)
		#TODO
	end

	def move
		if first_turn?
			report(0.33*$dimensions[:x], 0.33*$dimensions[:y])
		else
			opponent_points = @points.reject{|p| p.player == current_player}
			options = opponent_points.map{|p| p.generate_options}.uniq
			options.reject!{|o| @points.include? o}

			coords = []
			score = 0
			options.each do |o|
				possible_state = simulate_move(o)
				if possible_state.score > score
					coords = o
					score = possible_state.score
				end
			end
			report(coords)
		end
	end
end

###
$dimensions = {:x => 400, :y => 400}
game = Voronoi.new
