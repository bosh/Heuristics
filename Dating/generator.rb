class Person
	attr_accessor :n, :attributes
	def initialize(n)
		@n = n
		generate_weights!
		report
	end

	def generate_weights!
		zeros = [((n.to_f/3) - 3 + 6*rand).to_i, 0].max
		nonzeros = n - zeros
		pos = (nonzeros/2 + rand*nonzeros/4).to_i
		neg = nonzeros - pos
		positives = Array.new(pos, 1.0 / pos)
		negatives = Array.new(neg, -1.0 / pos)
		4.times do
			#positives
			doubles = Array.new((2 + pos*rand).to_i)
			doubles.map!{(pos*rand).floor}
			halves = Array.new(doubles.size)
			halves.map!{(pos*rand).floor}
			doubles.each{|d| positives[d] *= 2 }
			halves.each {|h| positives[h] /= 2 }
			#negatives
			doubles = Array.new((2 + neg*rand).to_i)
			doubles.map!{(neg*rand).floor}
			halves = Array.new(doubles.size)
			halves.map!{(neg*rand).floor}
			doubles.each{|d| negatives[d] *= 2 }
			halves.each {|h| negatives[h] /= 2 }
		end
		positive_total = positives.inject{|s,v| s += v}
		until positive_total <= 1
			positive_total -= positives.pop
			zeros += 1
		end
		if positive_total < 1
			positives[0] += 1 - positive_total
		end
		negative_total = negatives.inject{|s,v| s += v}
		until negative_total >= -1
			negative_total -= negatives.pop
			zeros += 1
		end
		if negative_total > -1
			negatives[0] -= -1 - negative_total
		end
		all = Array.new(zeros)
		all += negatives
		all += positives
		all.sort_by{rand}
		@attributes = all
	end

	def report
		File.new('person.txt', 'w') do |file|
			file.write @attributes.join("\n")
		end
	end
end

###

$n = gets().to_i
person = Person.new($n)