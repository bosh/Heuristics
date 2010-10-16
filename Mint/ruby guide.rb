'Quick Tour of Ruby'

	# Basic arithmetic in Ruby:
		2+3 #5
		3*2 #6

	# PEMDAS precedence:
		3*2+5 # 11

	# Assignment
		abc = 3*15.0 # Ruby will automatically convert to floats and numbers greater than integer limit without complaint
		ary = [1,2,3]
		symbol = :shiny

	# String and Array creation
		[1,2,3]*2				# [1,2,3,1,2,3]
		"Hey" * 3				# "HeyHeyHey"
		"one #{1 + 1} three"	# "one 2 three"
		'one #{1 + 1} three'	# "one #{1 + 1} three"

	# Collections
		a = [1,2,3]
		a.each do |value|
			puts value # Printing with newline. "p" gives more detail, "print" prints without newline
		end

		a.map {|i| i * 2} # returns the array [2,4,6] but leaves 'a' untouched

	# Ranges
		(1..10).to_a # [1,2,3,4,5,6,7,8,9,10]

	# Hashes
		hash = {}
		hash[:foo] = "bar"
		hash.each{|k,v| puts "Key #{k}   Value #{v}"}

	# Getting user input
		number = gets.to_i

	# Easy conversion
		to_s, to_a, to_i, to_f, to_sym

	# Logic and Truthiness
		true || false 	# true
		"foo" || false 	# "foo", which is truthy
		1 && 2 			# returns 2
		The only falsy values are false and nil. 0, [], and '' (empty string) are truthy

	# Everything is an object and descendant of the core Object class:

		# even nil
			nil.id # 4

		# new classes
			class Foo
				attr_accessor :bar, :quux # Automatic getters and setters for instance variables with @variable names

				def initialize(bar = "baz") # Default arguments
					@bar = bar
				end
			end

			blah = Foo.new("corge")
			blah.bar # "corge"

<<-HEREDOC
Why is Ruby Good?
	* Interpreted. Every statement returns a value. The only reason to explicitly write "return" in a method is to return early
	
	* Understandable. At least that's what hooked me on it. Method chains read like english (see Bang and Question mark methods...)
HEREDOC

	class Glass
		attr_accessor :liquid_amount

		def initialize(amt = .5); @liquid_amt = .5 end

		def empty?
			@liquid_amount == 0
		end

		def spill!
			@liquid_amount = 0
		end
	end

	g = Glass.new
	g.empty? # false
	g.spill!
	g.empty? # true

Why is Ruby Bad?
	 :SLOW # Ruby's not going to win a speed competition.


#Sample code from mint problem part one:

class CoinSet
	attr_accessor :coins #, ...
	#.......... skipping a bit

	def create_descendants						# Returns an array of new coinset possibilities (which are arrays of values)
		results = []
		deltas = (-11..-1).to_a + (1..11).to_a	# -11 to 11, skipping 0
		deltas.each do |delta|
			(0...4).each do |coin|				# For each possible coin to change
				set = @coins.sort				# Ensure deterministic value ordering. Side effect is creating a copy of the array
				set[coin] = set[coin] + delta	# Change the individual coin in the set. Ruby doesn't have ++ and --, but does have _num_ += _val_
				set.sort!						# Build in bang methods let you know you're changing something's value. This is in place sort.
				results << set unless (set.min <= 1 || set.max > 99 || set.uniq.size < 4) # Array pushing, minimum, maximum, and unique value finding
												# Discard if invalid coin values or duplicates
												# If and Unless can be put before their statements 'if blah; do_things end' == 'do_things if blah'
			end
		end
		results									# Return results. For clarity, "return" could optionally be placed here
	end
	def to_s; @coins.join "," end				# If you just ask Ruby to print an object, it'll call its to_s method automatically
end