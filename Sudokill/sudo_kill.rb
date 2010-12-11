require 'socket'
require 'matrix'
require 'mathn'

class SudoKiller
	attr_accessor :connection

	def initialize(host, port)
		@connection = TCPSocket.open(host, port)
		write
		play!
	end

	def read; @connection.readline end
	def write(str); @connection.puts(str) end

	def play!
		#TODO
	end
end

###

$host = ARGV[0] || 'localhost'
$port = (ARGV[1] || 44444).to_i
game = SudoKiller.new($host, $port)
