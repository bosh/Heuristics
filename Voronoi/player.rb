class Player
	attr_accessor :placements, :game
	def initialize(game)
		@game = game
		@placements = []
	end

	def add_placement(x, y)
		@placements << Placement.new(self, x, y)
	end

	def opponent_placements
		@game.players.reject{|p| p == self}.map{|p| p.placements}
	end

	def score
		@placements.map{|p| p.score}
	end
end