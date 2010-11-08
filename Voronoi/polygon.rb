class Polygon
	attr_accessor :center, :vertices
	def initialize(center, lines)
		@center = center
		lines.map! do |line|
			intersections = []
			lines.each{|other| intersections << Intersection.new(line, other) unless line == other }
			{:line => line, :intersections => intersections}
		end

		closest = {:distance => 9999, :intersection => nil}
		lines.each do |line|
			line[:intersections].each do |inter|
				if @center.distance_to(inter) < closest[:distance]
					closest[:intersection] = inter
					closest[:distance] = @center.distance_to(inter)
				end
			end
		end

		next_closest = {:distance => 9999, :intersection => nil}
		closest[:intersection].lines.each do |line|
			line_intersections = lines[lines.index(lines.select{|l| l[:line] == line}.first)][:intersections]
			line_intersections.each do |inter|
				if inter != closest[:intersection] && @center.distance_to(inter) < next_closest[:distance]
					next_closest[:intersection] = inter
					next_closest[:distance] = @center.distance_to(inter)
				end
			end
		end

		poly = [closest[:intersection], second_closest[:intersection]]
		unshift_line = poly.first.lines - poly[1].lines #should end up with only one
		push_line = poly.last.lines - poly[-2].lines #should also end up with only one
		open_lines = [unshift_line, push_line]


		get_next_closest from the two lines
		repeat until two open lines are ==
		create vertices from the intersections, put them in @vertices

		#TODO create polygon from set of lines
		#closest_intersection = nil
		#intersections = lines.map{|l| l.intersections(lines)}
		#intersections.each_with_index do |inter, i|
		#  inter.each do |p|
		#    dist = @center.distance_to(p)
		#    if dist < closest_intersection.distance_to(@center)
		#		closest_intersection = p
		#       closest_segment = i
		#    end
		#  end
		#end
	end

	def area
		area = 0.0
		p1 = vertices.first
		(2...vertices.length).each do |i|
			p2 = vertices[i-1]
			p3 = vertices[i]
			area += ((p1.x*(p2.y - p3.y) + p2.x*(p3.y-p1.y) + p3.x*(p1.y - p2.y))/2.0).abs
		end
	end
end