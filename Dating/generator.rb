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
		zeros = [((n.to_f/3) - 3 + 6*rand).to_i, 0].max
		zeros = [zeros, n - 2].min
		nonzeros = n - zeros
		pos = [(nonzeros/2 + rand*nonzeros/4).to_i, 1].max
		neg = nonzeros - pos
		positives = Array.new(pos, 1.0 / pos)
		negatives = Array.new(neg, -1.0 / neg)
		postives = skew(positives, 5, rand*0.5*positives.size)
		negatives = skew(negatives, 5, rand*0.5*negatives.size)
		#Round to three places
		positives.map!{|i| ((i*100).floor/100.0)}
		negatives.map!{|i| ((i*100).floor/100.0)}
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

	def skew(ary, times = 1, num = 2, floor = -1, ceil = 1)
		num = num.to_i
		(0...times).each do
			ups = []
			downs = []
			num.times{ ups << (ary.size*rand).floor}
			num.times{ downs << (ary.size*rand).floor}
			amounts = downs.map{|i| ary[i]*0.5}
			amounts.each_with_index do |v, i|
				amounts[i] = [amounts[i], floor - ups[i]].max
				amounts[i] = [amounts[i], ceil + downs[i]].min
				ary[ups[i]] += amounts[i]
				ary[downs[i]] -= amounts[i]
			end
		end
		ary
	end

	def report
		File.open(@path, 'w') do |file|
			file.print @attributes.join("\n")
		end
	end
end

###

$host = 'localhost'
$port = 20000
$filepath = './person.txt'
connection = TCPSocket.open($host, $port)
connection.puts "Person"

n = nil
while line = connection.gets
	puts line.chop
	if !n
		n = line.split(":")[1].to_i
		Person.new(n, $filepath)
		connection.puts $filepath
	end
end
connection.close
