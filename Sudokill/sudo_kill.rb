require 'socket'

class SudoKiller
	attr_accessor :connection, :current_board, :time_taken, :player_number, :player_count, :moves, :turn

	def initialize(host, port)
		connect(host, port)
		write("B0$H")
		play!
	end

	# Communication methods
	def connect(h, p);	@connection = TCPSocket.open(h, p) end
	def read;			l = @connection.readline; puts l; l end
	def write(str);		puts(str); @connection.puts(str + "\n") end
	def disconnect;		@connection.close end
	def send_move(row, col, val);	write("#{row} #{col} #{val}") end

	# Main loop
	def play!
		while line = read
			if line =~ /(READY|WAIT)/
				# do nothing, this is just waiting
			elsif line =~ /REJECT/ # we made a bad move :(
				# if this weren't an autofail, there would need to be a move undo-er method
			elsif line =~ /START\|(\d+)\|(\d+)\|(.*)/
				@moves = []
				@time_taken = 0
				@moves = []
				@turn = 0
				@player_number = $1.to_i
				@player_count = $2.to_i
				@board = Board.new(:text => $3.chomp)
			elsif line =~ /\A(\d+) (\d+) (\d+) (\d+)/
				#Idea, it would be cool to be able to run analysis on opponent moves and figure out their bias/preferences, and then spend more time computing and their expected path
				take_move!($1.to_i, $2.to_i, $3.to_i, $4.to_i)
			elsif line =~ /ADD\|(\d+)\|(\d+)\|(.*)/
				make_move!
			elsif line =~ /(WIN|LOSE)/
				puts "I #{$1}!"
				disconnect
				exit(0)
			end
		end
	end

	def advance_turn!
		@turn += 1
	end

	def update_board!(row, col, val)
		@current_board = @current_board.place(row, col, val)
	end

	# A move reported from the server, returns a Move
	def take_move!(row, col, number, player)
		@moves << [row, col, number]
		update_board!(row, col, val)
		advance_turn!
	end

	# A move from this instance, returns a Move
	def make_move!
		row, col, val, time_diff = lambda{
			start = Time.now
			row, col, val = make_move_for_player_and_board(@player_number, @board.clone)
			@moves << [row,col,val]
			send_move(row, col, val)
			[row, col, val, (Time.now - start)]
		}.call
		@time_taken += time_diff
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

class Board
	attr_accessor :cells, :placements, :turn, :row, :col

	def initialize(args = {})
		if args.has_key? :text
			@cells = args[:text].split("|").map{|line| line.split(" ").map{|c| c.to_i} }
		elsif args.has_key? :cells
			@cells = args[:cells].clone
			if args.has_key? :move
				@row = args[:move][:row]
				@col = args[:move][:col]
				@cells[@row][@col] = args[:move][:val]
			end
		end
		@turn = args.has_key?(:turn) ? args[:turn] : 0
		@placements = args[:skip_placements] ? [] : collect_all_placements
	end

	def collect_all_placements
		positions = if @row && @col
			collect_limited_options
		else
			collect_all_options
		end
		pos = []
		positions.each do |(row,col)|
			possible_values(row,col).each do |val|
				pos << Placement.new(self, row, col, val)
			end
		end
		pos
	end

	def collect_limited_options
		options = []
		(0..8).each do |i|
			options << [@row, i] if empty?(@row, i)
			options << [i, @col] if empty?(i, @col)
		end
		options.uniq!
	end

	def collect_all_options
		options = []
		(0..8).each do |r|
			(0..8).each do |c|
				options << [r,c] if empty?(r, c)
			end
		end
		options
	end

	def empty?(row, col)
		@cells[row][col] == 0
	end

	# Gets all the values in the current row, column, and cell, and finds values from 1 to 9 that are not already included in the set
	def possible_values(row, col)
		((1..9).to_a - (row_values(row) + col_values(col) + cell_values(row, col)).uniq).sort
	end

	# Returns the values already placed in the given row
	def row_values(row)
		(0..8).collect{|c| @cells[row, c]}
	end

	# Returns the values already placed in the given column
	def col_values(col)
		(0..8).collect{|r| @cells[r, col]}
	end

	def cell_values(row, col)
		cell_row = row/3
		cell_col = col/3
		(0..8).collect{|i| @cells[cell_row + i/3][cell_col + i%3] }
	end

	# Returns the board state for a board descendant of the current board, with a certain move taken
	def place(row, col, val)
		if path = @placements.select{|p| p.row == row && p.col == col && p.val = val}.first
			path.result
		else
			Placement.new(self, row, col, val).result
		end
	end
end

class Placement
	attr_accessor :row, :col, :val, :parent, :child, :turn

	def initialize(parent, row, col, val)
		@row = row
		@col = col
		@val = val
		@parent = parent
	end

	def result # Delay computation until necessary, but memoize afterwards
		@child ||= Board.new(:cells => parent.cells, :move => {:row => @row, :col => @col, :val => @val}, :turn => @parent.turn+1)
	end
end

###

$host = ARGV[0] || 'localhost'
$port = (ARGV[1] || 44444).to_i
game = SudoKiller.new($host, $port)
