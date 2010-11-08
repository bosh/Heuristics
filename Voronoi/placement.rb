class Placement < Point
	attr_accessor :player
	def initialize(player, x, y)
		super(x, y)
		@player = player
	end

	def bisector_to(point)
		Bisector.new(self, point)
	end

	def generate_possibilities(range = 4)
		possibilities = []
		([0, @x-range].max...[$dimensions[:x], @x+range].min).each do |i|
			([0, @y-range].max...[$dimensions[:y], @y+range].min).each do |j|
				possibilities << Point.new(i, j) unless (i == @x && j == @y)
			end
		end
		possibilities
	end

	def polygon
		#TODO
		bisectors = player.game.all_placements.map{|p| bisector_to(p)}
		Polygon.new(self, bisectors)
		#find all bisectors to all other points
		#make union of bisectors
		#return set of vertices that define polygon
	end
end