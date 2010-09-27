class ResultStore
	attr_accessor		:storage
	def initialize;		@storage = []			end
	def identify;		$idents	end #OPTIMIZATION ON LOOKUPS
	def best_unchecked_result #Returns the next-best choice to descend from, as the descendant algorithm is deterministic and thus pointless to re-run on a single best set
		unchecked = @storage.reject{|cs| cs.checked}
		scores = unchecked.map(&:score)
		unchecked[scores.index scores.min]
	end
	def best_result #Returns the lowest score found in ALL run sets
		scores = @storage.map(&:score)
		@storage[scores.index scores.min]
	end
	def add_result(coinset) #The actual point at which a coin set becomes a record object
		coinstring = coinset.sort.join ","
		@storage << CoinSet.new(coinset) unless identify.include? coinstring
		$idents << coinstring
	end
end

class CoinSet
	attr_accessor :coins, :score, :counts, :checked
	def initialize(coins)
		@checked = false
		@coins = coins.sort
		@counts = Array.new(100, [99, false])
		calculate_score
	end
	def calculate_score #Sets the score and counts.
		@coins.each{|c| @counts[c] = 1; @counts[100-c] = 1} # Finding the base case 1-coin sets
		
		<<-IDEA
			select all falses from coins, find the minimum number associated
			from that, get all values +- one coin value. set those to currentval + 1 || their min
			set current's false to a true
			continue until every false is gone (optimization, increment a counter until it reaches 100)
		IDEA
		@score = 0
		@counts.each_with_index.map do |c,i|
			@score += (i%5==0)? c*$frequency : c
		end
	end
	def create_descendants #Returns an array of new coinset possibilities (which are arrays of values)
		results = []
		deltas = (-13..-1).to_a + (1..13).to_a
		deltas.each do |delta|
			(0..4).each do |coin| #For each possible coin to change
				set = @coins.sort
				set[coin] = set[coin] + delta #Change the individual coin in the set
				set.sort!
				results << set unless (set.min < 1 || set.max > 99 || set.uniq.size < 5) #Discard if invalid coin values or duplicates
			end
		end
		results
	end
	def average; (@score * 1.0)/(80 + (19*$frequency)) end #Returns the weighted average
	def to_s; @coins.join "," end
end
#####################################
$frequency = gets.to_f #Get the frequency of multiples of 5
$idents = []
start_time = Time.now
res = ResultStore.new
seeds = [	[1,5,10,25,50], #Standard US
			[1,3,11,37,50], #Internet recommended!
			[1,5,16,23,33], #From test data for N == 1
			[1,5,7,25,40],  #From test data for low N's
			[1,5,20,30,45]  #From test data for high N's
		]
seeds.each{|seed| res.add_result(seed)} #Seed the data with a decent selection of starting sets
while Time.now - start_time < 29 #How many seconds to quit out at
  current = res.best_unchecked_result
  current.create_descendants.each{|d| res.add_result d }
  current.checked = true
end
best = res.best_result
puts "Best set found: #{best.to_s}\nScore: #{best.score}\tWeighted Avg: #{best.average}\nCounts: #{best.counts.join ','}"
puts (Time.now - start_time).to_s + " seconds elapsed."
puts res.storage.size.to_s + " combinations attempted."
