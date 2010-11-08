class Polygon
	attr_accessor :center, :vertices
	def initialize(center, lines)
		@center = center
		lines.map! do |line| #turn bisectors and edges into line-intersection sets
			intersections = []
			lines.each{|other| intersections << Intersection.new(line, other) unless line == other }
			{:line => line, :intersections => intersections}
		end

		poly = []
		closest = {:distance => 9999, :intersection => nil}
		lines.each do |line| #get the closest intersection to the center
			line[:intersections].each do |inter|
				if @center.distance_to(inter) < closest[:distance]
					closest[:intersection] = inter
					closest[:distance] = @center.distance_to(inter)
				end
			end
		end
		poly.push closest[:intersection]

		next_closest = {:distance => 9999, :intersection => nil}
		poly.first.lines.each do |line|
			lines.select{|l| l[:line] == line}.first[:intersections].each do |inter| #for all intersections on the current line
				if !poly.include?(inter) && @center.distance_to(inter) < next_closest[:distance] #skipping already used intersections
					next_closest[:intersection] = inter
					next_closest[:distance] = @center.distance_to(inter)
				end
			end
		end
		poly.push next_closest[:intersection]

		until poly.size > 2 && poly.first.lines - poly[1].lines == poly.last.lines - poly[-2].lines #test that the chain reloops
			unshift_line = poly.first.lines - poly[1].lines #should end up with only one
			push_line = poly.last.lines - poly[-2].lines #should also end up with only one
			open_lines = [unshift_line, push_line]

			next_closest = {:distance => 9999, :intersection => nil, :line}
			open_lines.each do |line|
				lines.select{|l| l[:line] == line}.first[:intersections].each do |inter| #for all intersections on the current line
					if !poly.include?(inter) && @center.distance_to(inter) < next_closest[:distance] #skipping already used intersections
						next_closest[:intersection] = inter
						next_closest[:distance] = @center.distance_to(inter)
						next_closest[:line] = line
					end
				end
			end

			if next_closest[:line] == push_line
				poly.push next_closest[:intersection]
			elsif next_closest[:line] == unshift_line
				poly.unshift next_closest[:intersection]
			end
		end

		@vertices = poly
	end

	def area
		area = 0.0
		p1 = @vertices.first
		(2...@vertices.length).each do |i|
			p2 = @vertices[i-1]
			p3 = @vertices[i]
			area += ((p1.x*(p2.y - p3.y) + p2.x*(p3.y-p1.y) + p3.x*(p1.y - p2.y))/2.0).abs
		end
	end
end