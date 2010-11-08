class Player
	attr_accessor :placements, :game
	def initialize(game)
		@game = game
		@placements = []
	end

	def opponent_placements
		@game.players.reject{|p| p == self}.map{|p| p.placements}
	end
end