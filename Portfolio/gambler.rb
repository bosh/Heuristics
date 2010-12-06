require 'socket'

class ExpectedValue
	attr_accessor :weights, :probabilities, :dot_values, :value
	def initialize(weights, probs, calculate = true)
		@weights = weights
		@probabilities = probs
		calculate! if calculate
	end

	def calculate!
		@dot_values = []
		(0...@weights.size).each{|i| @dot_values << @weights[i]*@probabilities[i]}
		@value = @dot_values.inject{|sum,v| sum += v }
	end

	def skew_probabilities(direction)
		if direction == :high
			temp = @probabilities[2]
			@probabilities[2] -= temp*0.5
			@probabilities[0] += temp*0.5
		elsif direction == :low
			temp = @probabilities[0]
			@probabilities[0] -= temp*0.5
			@probabilities[2] += temp*0.5
		end
	end
end

class Gamble
	attr_accessor :id, :game, :returns, :probabilities, :links, :category, :history, :category_belief_history
	def initialize(game, id, rh, ph, rm, pm, rl, pl)
		@game = game
		@id = id.to_i
		@returns = {
			:low => rl.to_f,
			:med => rm.to_f,
			:high => rh.to_f
		}
		@probabilities = {
			:low => pl.to_f,
			:med => pm.to_f,
			:high => ph.to_f
		}
		@links = []
		@category = nil
		@category_belief_history = []
		@history = []
	end

	def linked_gambles
		@links.map{|l| l.gambles}.flatten.uniq - [gamble]
	end

	def fully_linked_group?
		@game.fully_linked_system?(self)
	end

	def full_link_chain
		@game.full_link_chain_from(self)
	end

	def expected_value(class_guess, calculate = false)
		pre_class_ev = ExpectedValue.new([@returns[:high],[@returns[:med],[@returns[:low]], [@probabilities[:high],[@probabilities[:med],[@probabilities[:low]], calculate)
		guessed_post_class_ev = pre_class_ev.skew_probabilities(class_guess)
		group_size = fully_linked_group?
		link_chain_expectations = case group_size
		when 1
			[0,1,0]
		when 2
			#h = pr this second * pr first was h |other was first
			#m = pr this first + pr this was second * pr first was m |other was first
			#l = pr this second * pr first was l |other was first
			[0,1,0] #h,m,l
		when 3
			#h = pr this second * (pr first was h |other was others.first + pr first was h |other was others.second)
			# 	+pr this third * (pr first two were HH (both orders))
			#m = pr this first + pr this was second * (
			#	pr first was others.first * pr first was m |other was others.first
			#	+pr first was others.second pr first was m |other was others.second
			#)	+pr this third * (pr first two were not HH or LL)
			#l = pr this second * (pr first was l|other was others.first + pr first was l |other was others.second
			# 	+pr this third * (pr first two were LL (both orders))
			[0,1,0] #h,m,l
		when 4
			#h = pr this was first * pr this is h + pr this was second and the first was h + this was third and first two were HH (both ways) + this was fourth and first three were HHH, HHL, HHM, HLH, LHH, HMH, MHH
			#m = pr this was first * pr this is m + pr this was second and the first was m for all firsts
			#	+pr this was third * pr first two were not HH or LL (both orders both times)
			#	+pr this was third * pr first three were HMM, HML, HLM, MMM, MHL, MLH, MML, MMH, MLM, MHM, LMM, LHM, LMH
			#l = pr this was first * pr this is l + pr this was second and the first was l + this was third and first two were HH (both ways) + this was fourth and first three were LLL, LlH, LLM, LHL, HLL, LML, MLL
			[0,1,0] #h,m,l
		else
			[0,1,0]
		end
	end

	def link_chain_expectations
		group = linked_gambles
		probabilities = []
	end
end

class Link
	attr_accessor :gambles
	def initialize(gamble_one, gamble_two)
		@gambles = [gamble_one.to_i, gamble_two.to_i]
	end
end

class Gambler
	attr_accessor :gambles, :links, :history, :gametype, :connection
	def initialize(gametype, host, port)
		@gambles = []
		@links = []
		@history = []
		@gametype = gametype
		@connection = TCPSocket.open(host, port)
		load_data
		if gametype == :short
			play_short_game
		elsif gametype == :long
			play_long_game
		end
	end

	def load_data
		mode = nil
		File.readlines('data.txt') do |line|
			if line =~ /#gambleatts/i
				mode = :gambleatts
			elsif line =~ /#gamble/
				mode = :gamble
			elsif line =~ /#link/
				mode = :link
			elsif mode == :gamble
				line =~ /(\d+), (\d+\.\d+), (\d+\.\d+), (\d+\.\d+), (\d+\.\d+), (\d+\.\d+), (\d+\.\d+)/
				@gambles << Gamble.new(self, $1, $2, $3, $4, $5, $6)
			elsif mode == :gambleatts #This will change when category is implemented as a 0-15 number
				line =~ /(\d+), (\d)/
				@gambles.select{|g| g.id == $1.to_i}.first.category = $2.to_i
			elsif mode == :link
				line =~ /(\d+), (\d+)/
				add_link($1.to_i, $2.to_i)
			end
		end
	end

	def add_link(id_one, id_two)
		link = Link.new(id_one, id_two)
		@gambles.select{|g| [id_one, id_two].include? g.id}.each{|g| g.links << link}
		@links << link
	end

	def play_short_game
		#TODO
	end

	def play_long_game
		#TODO
	end

	def gambles_with_category(cat)
		@gambles.select{|g| g.category == cat}
	end

	def fully_linked_system?(gamble)
		other_gambles = gamble.linked_gambles
		own_set = [gamble] + other_gambles
		other_gambles.each{|g| (g.linked_gambles + [g]).each{|gam| if !own_set.include?(gam){ return false }}}
		return own_set.size #fallthrough return that returns the system size
	end

	def full_link_chain_from(gamble)
		open_links = gamble.links
		checked = [gamble]
		next_gambles = open_links.map{|l| l.gambles.reject{|g| !checked.include?(g)}}.flatten.uniq
		while !next_gambles.empty?
			open_links = next_gambles.map{|g| g.links}.flatten.uniq
			checked += next_gambles
			next_gambles = open_links.map{|l| l.gambles.select{|g| !checked.include?(g)}}.flatten
		end
	end
end

###

gametype = (ARGV[0] || "short").to_sym
host = (ARGV[1] || "localhost")
port = (ARGV[2] || 20000).to_i
Gambler.new(gametype, host, port)
