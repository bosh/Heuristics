require 'socket'
$hostname = "localhost"
$port = 20000

class Game
	attr_accessor :players, :current_player, :connection, :moves
	def initialize(simulation = false)
		if !simulation
			connect!
			play!
			disconnect!
		end
	end

	def connect!
		@connection = TCPSocket.open($hostname, $port)
		while line = @connection.gets()
			puts line
			break if line =~ /\d+\W+(\d+)\W+(\d+)\W+(\d+)/
		end
		$move_count = $1.to_i
		$player_count = $2.to_i
		$player_number = $3.to_i
		@players = Array.new($player_count, Player.new(self))
		@current_player = @players[$player_number] #Assumes players count 1-Number, not 0-Number-1
	end

	def disconnect!
		@connection.close
	end

	def play!
		while line = @connection.gets
			puts line
			break if line =~ /WIN/i
			break if line =~ /LOSE/i
			if line =~ /YOURTURN/i
				respond(choose_move)
			elsif line =~ /(\d+)\W+(\d+)\W+(\d+)/
				player = @players[$3.to_i]
				x = $1.to_i
				y = $2.to_i
				player.add_placement(x, y)
			else
				puts "line did not match any known format"
			end
		end
	end

	def choose_move
		puts "choosing move"
		if first_turn?
			Point.new($dimensions[:x]*0.33, $dimensions[:y]*0.33)
		else
			options = generate_options.flatten
			point = nil
			score = 0
			options.each do |o| #YUUUUUUP all I do is choose the most score I can get at any step.
				future = simulate_future(o)
				future_score = future.current_player_score
				if future_score > score
					score = future_score
					point = o
				end
			end
			@current_player.add_placement(point.x, point.y)
			point
		end
	end

	def first_turn?
		all_placements.size == 0
	end

	def all_placements
		@players.map{|p| p.placements}.flatten
	end

	def opponents
		@players.reject{|p| p == @current_player}
	end

	def opponent_placements
		opponents.map{|p| p.placements}
	end

	def generate_options
		opponent_placements.flatten.map{|p| p.generate_possibilities}
	end

	def simulate_future(point)
		simulation = Game.new()
		simulation.players = Array.new(self.players.size, Player.new(simulation))
		simulation.current_player = simulation.players[$player_number]
		simulation.players.each_with_index do |player, index|
			@players[index].placements.each do |placement|
				player.add_placement(placement.x, placement.y)
			end
		end
		simulation.current_player.add_placement(point.x, point.y)
		simulation
	end

	def respond(point)
		puts "Made move: (#{point.x.to_i}, #{point.y.to_i})"
		@connection.puts("#{point.x.to_i} #{point.y.to_i}")
	end

	def scores
		@players.map{|p| p.score}
	end

	def current_player_score
		scores[@players.index(current_player)]
	end
end