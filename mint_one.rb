class ResultStore
	attr_accessor		:storage
	def initialize;		@storage = [] end
	#def identify;		@storage.map(&:to_s)	end #Identify every coinset object run and saved in storage
	def identify;		$idents	end #OPTIMIZATION ON LOOKUPS
	def best_unchecked_result #Returns the next-best choice to descend from, as the descendant algorithm is deterministic and thus pointless to re-run on a single best set
		unchecked = @storage.reject{|cs| cs.checked}
		scores = unchecked.map(&:score)
		idx = scores.index scores.min
		unchecked[idx]
	end
	def best_result #Returns the lowest score found in ALL run sets
		scores = @storage.map(&:score)
		idx = scores.index scores.min
		@storage[idx]
	end
	def add_result(coinset) #The actual point at which a coin set becomes a record object
		coinstring = coinset.sort.join ","
		@storage << CoinSet.new(coinset) unless identify.include? coinstring
		$idents << coinstring #OPTIMIZATION ON LOOKUPS
	end
end

class CoinSet
	attr_accessor :coins, :score, :counts, :checked
	def initialize(coins)
		@checked = false
		@coins = coins.sort
		@counts = Array.new(100, 99)
		calculate_score
	end
	def calculate_score #Sets the score and counts.
		@coins.each{|c| @counts[c] = 1}
		(0...@coins.min).each{|c| @counts[c] = c} #Identifies the penny-required cases from 1 to the next lowest coin
		(0..99).each do |i| #Iterate through in a pattern that guarantees every coin value reached will already be at its minimum value
			@counts[i+1] = [@counts[i]+1, @counts[i+1]].min unless i+1 > 99	#Set the next index to the current plus a penny
			@coins.each do |c|	#For every non-penny coin, set the index that would be reached by their addition to the current plus one coin
				@counts[i+c] = [@counts[i]+1, @counts[i+c]].min unless i+c > 99
			end
		end
		@score = 0
		@counts.each_with_index.map do |c,i|
			@score += (i%5==0)? c*$frequency : c
		end
	end
	def create_descendants #Returns an array of new coinset possibilities (which are arrays of values)
		results = []
#    	deltas = [-5, -2, -1, 1,2,5] #Fewer delta cases to try more things quickly
#    	deltas = [-5,-4,-3,-2,-1,1,2,3,4,5] #More deltas near the coinset to cover every possibility
#    	deltas = [-10,-7,-5,-3,-1,1,3,5,7,10] #Wide and shallow coverage of deltas because the chance that every possible delta needs to be checked is small
    	deltas = [-17, -13] + (-11..-1).to_a + (1..11).to_a + [13, 17] #Deep central coverage with possibilities further away too
#		deltas = (-21..-1).to_a + (1..21).to_a
		deltas.each do |delta|
			(0...4).each do |coin| #For each possible coin to change
				set = @coins.sort
				set[coin] = set[coin] + delta #Change the individual coin in the set
				set.sort!
				results << set unless (set.min <= 1 || set.max > 99 || set.uniq.size < 4) #Discard if invalid coin values or duplicates
			end
		end
		results
	end
	def average; (@score * 1.0)/(80 + (19*$frequency)) end #Returns the weighted average
	def to_s; @coins.join "," end
end
#####################################
puts "Please enter the N (frequency):"
$frequency = gets.to_f #Get the frequency of multiples of 5
puts "You entered '#{$frequency}'"
$idents = []
start_time = Time.now
res = ResultStore.new
seeds = [	[5,10,25,50], #Standard US
			[3,11,37,50], #Internet recommended!
			[5,16,23,33], #From test data for N == 1
			[5,7,25,40],  #From test data for low N's
			[5,20,30,45]  #From test data for high N's
		]
seeds.each{|seed| res.add_result(seed)} #Seed the data with a decent selection of starting sets
attempts = 0
while Time.now - start_time < 119 #How many seconds to quit out at
  attempts += 1
  current = res.best_unchecked_result
  current.create_descendants.each{|d| res.add_result d }
  current.checked = true
end
best = res.best_result
puts "Best set found: 1,#{best.to_s}\nScore: #{best.score}\tWeighted Avg: #{best.average}\nCounts: #{best.counts.join ','}"
puts (Time.now - start_time).to_s + " seconds elapsed."
puts "Top #{attempts} examined, #{res.storage.size} combinations attempted."
