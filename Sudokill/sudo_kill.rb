require 'socket'

class SudoKiller
	attr_accessor :connection, :board, :time_taken, :player_number, :player_count, :moves, :turn

	def initialize(host, port)
		connect(host, port)
		write("B0$H")
		play!
	end

	# Communication methods
	def connect(h, p);	@connection = TCPSocket.open(h, p) end
	def read;			@connection.readline end
	def write(str);		@connection.puts(str) end
	def disconnect;		@connection.close end
	def send_move(row, col, val);	write("#{row} #{col} #{val}") end

	# Main loop
	def play!
		@moves = []
		while line = read
			if line =~ /(READY|WAIT)/
				# do nothing, this is just waiting
			elsif line =~ /REJECT/
				# we made a bad move :(
				# if this weren't an autofail, there would need to be a move undo-er method
			elsif line =~ /START\|(\d+)\|(\d+)\|(.*)/
				@time_taken = 0
				@player_number = $1.to_i
				@player_count = $2.to_i
				create_board!($3.chomp)
				@moves = []
				@turn = 0
			elsif line =~ /\A(\d+) (\d+) (\d+) (\d+)/
				#Idea, it would be cool to be able to run analysis on opponent moves and figure out their bias/preferences, and then spend more time computing and their expected path
				take_move!($1.to_i, $2.to_i, $3.to_i, $4.to_i)
			elsif line =~ /ADD\|(\d+)\|(\d+)\|(.*)/
				# create_board!($3.chomp) #redundant if you can guarantee the deltas received give full information
				make_move!
			elsif line =~ /(WIN|LOSE)/
				puts "I #{$1}!"
				disconnect
				exit(0)
			end
		end
	end

	def create_board!(text)
		@board = text.split("|").map{|line| line.split(" ").map{|c| c.to_i} }
	end

	def advance_turn!
		@turn += 1
	end

	def update_board!(row, col, val)
		@board[row][col] = val
	end

	# A move reported from the server, returns a Move
	def take_move!(row, col, number, player)
		@moves << [row, col, number]
		update_board!(row, col, val)
		advance_turn!
	end

	# A move from this instance, returns a Move
	def make_move!
		row, col, val = nil, nil, nil
		@time_taken += lambda{ |start|
			@moves << move = row, col, val = make_move_for_player_and_board(@player_number, @board.clone)
			send_move(row, col, val)
			@time_taken += (Time.now - start)
		}.call(Time.now)

		update_board!(row, col, val) # If the server echoes your move to you, this is redundant.
		advance_turn!
	end

	# Simulation moves for any player, returning a hash {:board, :move}
	def make_move_for_player_and_board(number, board)	#MAJOR TODO
		if number == @player_number
			find_optimal_move(board, row, col)
		else #other player's turn, simulating appropriately
			find_available_moves(board, row, col)
		end
	end
end

###

$host = ARGV[0] || 'localhost'
$port = (ARGV[1] || 44444).to_i
game = SudoKiller.new($host, $port)
