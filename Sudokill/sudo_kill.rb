require 'socket'

class SudoKiller
	attr_accessor :connection, :board, :player_number, :player_count, :moves

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
		while line = read
			if line =~ /START\|(\d+)\|(\d+)\|(.*)/
				@player_number = $1.to_i
				@player_count = $2.to_i
				create_board!($3.chomp)
			elsif line =~ /\A(\d+) (\d+) (\d+) (\d+)/
				#		   row, col, val, player
				@moves << [$1,  $2,  $3,  $4].map(&:to_i)
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

	def make_move!
		#TODO
		send_move(row, col, val)
	end
end

###

$host = ARGV[0] || 'localhost'
$port = (ARGV[1] || 44444).to_i
game = SudoKiller.new($host, $port)
