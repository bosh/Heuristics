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
		bisectors = player.game.all_placements.map{|p| self.bisector_to(p)}
		boundaries = [
			Line.new(Point.new(0, 0), Point.new(0, $dimensions[:y])),
			Line.new(Point.new(0, 0), Point.new($dimensions[:x], 0)),
			Line.new(Point.new($dimensions[:x], $dimensions[:y]), Point.new(0, $dimensions[:y])),
			Line.new(Point.new($dimensions[:x], $dimensions[:y]), Point.new($dimensions[:x], 0))
		]
		Polygon.new(self, bisectors += boundaries)
	end

	def score
		self.polygon.area
	end
end