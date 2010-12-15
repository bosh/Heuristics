require 'socket'

class Person
	attr_accessor :n, :attributes, :path
	def initialize(n, path)
		@n = n
		@path = path
		generate_weights!
		report
	end

	def generate_weights!
		zeros = [[((n.to_f/5) - 3 + 6*rand).to_i, 0].max, n/2].min
		nonzeros = n - zeros
		pos = [(nonzeros/2 + rand*nonzeros/4).to_i, 1].max
		neg = nonzeros - pos
		positives = Array.new(pos)
		negatives = Array.new(neg)
		positives.map!{|i| rand*100}
		negatives.map!{|i| -(rand*100)}
		pos_sum = positives.inject{|s,v| s += v}
		neg_sum = positives.inject{|s,v| s += v}
		#Round to three places
		positives.map!{|i| ((i*100).floor/(pos_sum*100.0))}
		negatives.map!{|i| ((i*100).floor/(neg_sum*100.0))}
		until positives.inject{|s,v| s += v} == 1
			positives[0] += 1 - positives.inject{|s,v| s += v}
			positives.map!{|i| ((i*100).round/100.0)}
		end
		until negatives.inject{|s,v| s += v} == -1
			negatives[0] += -1 - negatives.inject{|s,v| s += v}
			negatives.map!{|i| ((i*100).round/100.0)}
		end
		all = Array.new(zeros, 0)
		all += negatives
		all += positives
		puts all.join("\t")
		@attributes = all.sort_by{rand}
	end

	def report
		File.open(@path, 'w+') do |file|
			file.print @attributes.join("\n")
		end
	end
end

###

$host = ARGV[0] || 'localhost'
$port = (ARGV[1] || 20000).to_i
$filepath = '/tmp/person.txt'
# connection = TCPSocket.open($host, $port)
# connection.puts "Person"

n = nil
# while line = connection.gets
# 	puts line.chop
# 	if !n
# 		n = line.split(":")[1].to_i
		Person.new(30, $filepath)
# 		connection.puts $filepath
# 	end
# end
# connection.close
