class DatingGame
	attr_accessor :candidates, :n, :connection
	def initialize(host, port)
		@connection = TCPSocket.open(host, port)
		get_n
		@candidates = []
		20.times do
			get_pregenerated_candidate
		end
		play!
	end

	def get_n
		line = @connection.readline
		@n = line.split(":")[1].to_i
	end

	def get_pregenerated_candidate
		line = @connection.readline
		@candidates << PregenCandidate.new(line, @n)
	end

	def play!
		#TODO
	end

	def submit_candidate
		#TODO
	end
end

class Candidate
	attr_accessor :score, :attributes, :n
	def initialize
		#TODO
	end
end

class PregenCandidate < Candidate
	def initialize(line, n)
		@n = n
		line = line.split(":")
		@score = line.shift.to_i
		@attributes = line.map(&:to_f)
	end
end

###

$host = 'localhost'
$port = 20000
game = DatingGame.new($host, $port)
