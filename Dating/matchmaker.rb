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
		@connection.puts "Matchmaker"
		while line = @connection.gets
			puts line
			if line =~ /N:\d+/ && !@n		#format: N:100
				@n = line.split(":").last.to_i
			elsif @candidates.size < 20		#format: SCORE1:v1:v2: ... :vn
				@candidates << PregenCandidate.new(line, @n)
			else							#format: SCORE:0:0:0
				@candidates.last.score = line.split(":")[1].to_f
				c = generate_new_candidate
				@candidates << c
				@connection.puts c.to_submit
			end
		end
	end

	def generate_new_candidate
		attr_ary = case candidates.size
		when 20	#The 21st candidate should be the best candidate thus far, made into a bit vector
			absolute_scores = candidate_scores.map{|i| i.abs}
			best_thus_far = @candidates[absolute_scores.index(absolute_scores.max)]
			if best_thus_far.score > 0 #customized rounding on all scores for the best known candidate thus far
				best_thus_far.attributes.map{|v| v < 0.4 ? 0 : v >= 0.55 ? 1 : 0}
			else #a reverse candidate should have a set of reversed scores
				best_thus_far.attributes.map{|v| v > 0.6 ? 0 : v <= 0.45 ? 1 : 0}
			end
		when 21	#Wide square wave (one period)
			Array.new((@n/2.0).floor, 1) + Array.new((@n/2.0).ceil, 1)
		when 22	#Two period square wave
			tmp = Array.new((@n/4.0).ceil, 1) + Array.new((@n/4.0).round, 0) + Array.new((@n/4.0).floor, 1)
			tmp += Array.new(@n - tmp.size, 0)
			tmp
		when 23 #Four period square wave
			half = Array.new((@n/8.0).ceil, 1) + Array.new((@n/8.0).round, 0) + Array.new((@n/8.0).round, 1)
			half += Array.new((@n/2.0 - half.size).floor, 0) + half
			half += Array.new(@n - half.size, 0)
			half
		when 24	#Alternating on-off attributes (N/2 period square wave) (done in 0-1-0-1 pattern as all others start with 1 and end with 0 if even length)
			(0...@n).map{|i| i%2==0 ? 0 : 1}
		else #After sacrificing five to crazy ideas, why not just let the optimizer work? B)
			x = candidate_attributes_matrix
			y = candidate_scores
			w_star = (x.t * x).inv * y
			w_star.to_a.flatten.map{|v| v.abs < 0.33 ? 0 : v >= 0.55 ? 1 : 0} #1 for attrs we want, anything for zeros, 0 for attrs we dont want
		end
	end

	def candidate_scores; Matrix[@candidates.map{|c| [c.score]} end
	def candidate_attributes_matrix; Matrix[@candidates.map(&:attributes)] end
end

class Candidate
	attr_accessor :score, :attributes, :n
	def initialize(attrs)
		@score = nil
		@attributes = attrs
		@n = @attributes.length
	end

	def to_submit; @attributes.join(":") end
end

class PregenCandidate < Candidate
	def initialize(line, n)
		@n = n
		line = line.split(":")
		@score = line.shift.to_f
		@attributes = line.map(&:to_f)
	end
end

###

$host = ARGV[0] || 'localhost'
$port = (ARGV[1] || 20000).to_i
game = DatingGame.new($host, $port)
