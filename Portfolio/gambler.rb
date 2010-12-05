require 'socket'

class Gamble
	attr_accessor :id, :returns, :probabilities, :links, :category, :history
	def initialize(id, rh, ph, rm, pm, rl, pl)
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
		@history = []
	end

	def linked_gambles
		@links.map{|l| l.gambles}.flatten.uniq - [gamble]
	end

	def decompose_system
		#TODO
	end
end

class Link
	attr_accessor :gambles
	def initialize(gamble_one, gamble_two)
		@gambles = [gamble_one, gamble_two]
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
				@gambles << Gamble.new($1, $2, $3, $4, $5, $6)
			elsif mode == :gambleatts #This will change when category is implemented as a 0-15 number
				line =~ /(\d+), (\d), (\d), (\d), (\d)/
				category = 8*($2.to_i) + 4*($3.to_i) + 2*($4.to_i) + 1*($5.to_i)
				@gambles.select{|g| g.id == $1.to_i}.first.category = category
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
