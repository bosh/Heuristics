require 'socket'
require 'matrix'
require 'mathn'

class DatingGame
	attr_accessor :candidates, :n, :connection
	def initialize(host, port)
		@connection = TCPSocket.open(host, port)
		@n = nil
		@candidates = []
		play!
	end

	def play!
		reading_for_score = false
		while line = @connection.gets
			puts line
			if line =~ /N:\d+/ && !@n
				@n = line.split(":").last.to_i
			elsif @candidates.size < 20
				@candidates << PregenCandidate.new(line, @n)
			elsif reading_for_score
				@candidates.last.score = line.to_f
				reading_for_score = false
			else
				c = generate_new_candidate
				@candidates << c
				@connection.puts c.to_submit
				reading_for_score = true
			end
		end
	end

	def generate_new_candidate
		#TODO this is the meat, innit
	end
end

class Candidate
	attr_accessor :score, :attributes, :n
	def initialize
		#TODO
	end

	def to_submit; @attributes.join(":") end
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

$host = ARGV[0] || 'localhost'
$port = (ARGV[1] || 20000).to_i
game = DatingGame.new($host, $port)
