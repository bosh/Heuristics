require 'socket'
$hostname = "localhost"
$port = 23000

class Game
	attr_accessor :players, :scores, :current_player, :connection, :moves
	def initialize
		connect!
		play!
		disconnect!
	end

	def connect!
		@connection = TCPSocket.open($hostname, $port)
		while line = @connection.gets()
			break if line =~ /(\d+)\W+(\d+)\W+(\d+)/
		end
		$move_count = $1
		$player_count = $2
		$player_number = $3
		@players = Array.new($player_count, Player.new(self))
		@current_player = @players[$player_number - 1] #Assumes players count 1-Number, not 0-Number-1
	end

	def disconnect!
		@connection.close
	end

	def play!
		while line = @connection.gets
			#TODO
			#run wait for message loop here
			#read in messages
			#if point data, add it to a player
			#if asking for a move
			respond choose_move
		end
	end

	def choose_move
		if first_turn?
			Point.new($dimensions[:x]*0.33, $dimensions[:y]*0.33)
		else
			@scores = nil

			options = generate_options
			point = []
			score = 0
			options.each do |o| #YUUUUUUP all I do is choose the most score I can get at any step.
				future = simulate_future(o)
				if future.current_player_score > score
					score = future.current_player_score
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

	def scores
		@scores ||= @players.map{|p| p.score}
	end

	def current_player_score
		scores[@players.index(current_player)]
	end
end