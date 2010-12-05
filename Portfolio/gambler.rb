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
		load_data
		@connection = TCPSocket.open(host, port)
		if gametype == :short
			play_short_game
		elsif gametype == :long
			play_long_game
		end
	end

	def load_data
		#TODO
	end

	def play_short_game
		#TODO
	end

	def play_long_game
		#TODO
	end
end

###

gametype = (ARGV[0] || "short").to_sym
host = (ARGV[1] || "localhost")
port = (ARGV[2] || 20000).to_i
Gambler.new(gametype, host, port)
