class Game
	attr_accessor :players, :current_player, :connection, :moves
	def initialize
		@players = []
		connect!
		play!
	end

	def connect!
		#connect
		#find out player number
		#find out total players in game
		#find out moves per player
		#create that many players
		#assign current_player whichever one this client is
	end

	def play!
		#TODO
		#run wait for message loop here
		#read in messages
		#if point data, add it to a player
		#if asking for a move
		respond choose_move
	end

	def choose_move
		if first_turn?
			Point.new($dimensions[:x]*0.33, $dimensions[:y]*0.33)
		else
			options = generate_options
			point = []
			score = 0
			options.each do |o| #YUUUUUUP all I do is choose the most score I can get at any step.
				o_score = simulate_future(o)
				if o_score > score
					score = o_score
					point = o
				end
			end
			point
		end
	end

	def first_turn?
		all_placements.size == 0
	end

	def all_placements
		@players.map{|p| p.placements}.flatten
	end

	def generate_options
		@current_player.opponent_placements.map{|p| p.generate_possibilities}
	end

	def simulate_future
		#TODO
		#clone current state, recalculate bisectors, sum area
		#returns a score
	end

	def respond
		#TODO
		#send message through the connection
	end
end