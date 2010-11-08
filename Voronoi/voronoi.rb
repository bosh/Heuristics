# Voronoi problem, client app

class Point
	attr_accessor :owner, :x, :y, :bisectors
	def initialize(owner, x, y, game)
		@owner = owner
		@x = x
		@y = y
		@game = game
		@bisectors = @game.points.map{|p| self.create_bisector(p)}
	end

	def coords
		{:x => @x, :y => @y}
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

	def create_bisector(point)
		Bisector.new(self, point)
	end
end

class Bisector
	attr_accessor :points, :midpoint, :slope
	def initialize(point_one, point_two)
		@points = [point_one, point_two]
		@midpoint = point_one.midpoint_with(point_two)
		@slope = point_one.slope_with(point_two)
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
	attr_accessor :points, :dimensions, :players, :player_number
	def initialize
		@dimensions = $dimensions
		@points = []
		@player_number = get_player_number
	end

	def get_player_number
		#TODO socket related #Assigns number told by connection
	end

	def add_point(point)
		@points.each do |p|
			p.bisectors << p.bisector_with(point)
		end
		@points << point
	end
end

###
$dimensions = {:x => 500, :y => 500}
game = Voronoi.new
