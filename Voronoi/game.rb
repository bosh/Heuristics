class Game
	attr_accessor :players, :current_player
	def initialize
		@players = []
		connect!
		play!
	end

	def connect!
		#connect
		#find out player number
		#find out total players in game
		#create that many players
		#assign current_player whichever one this client is
	end

	def play!
		#read in messages
		#if point data, add it to a player
		#if asking for a move
		if first_turn?
			respond(Point.new($dimensions[:x]*0.33, $dimensions[:y]*0.33))
		else
			options = generate_options
			point = []
			score = 0
			options.each do |o|
				o_score = simulate_future(o)
				if o_score > score
					score = o_score
					point = o
				end
			end
			respond point
		end
	end

	def respond

	end

	def generate_options
		@current_player.opponent_placements.map{|p| p.generate_possibilities}
	end

	def simulate_future
		#TODO
		#clone current state, recalculate bisectors, sum area
		#returns a score
	end

	def all_placements
		@players.map{|p| p.placements}.flatten
	end
end