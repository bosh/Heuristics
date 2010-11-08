class Polygon
	attr_accessor :center, :vertices
	def initialize(center, lines)
		@center = center
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
		#after getting the closest, get the next closest point on said bisector
		#then get the bisectors associated with those two vertices
		#find their closest, non-outside intersection
		#get the new pair of unclosed/unpaired bisector/segments
		#repeat until both unclosed are from the same bisector parent (ie the close each other)
		#dump out the collected set as a polygon
	end

	def area
		area = 0.0
		p1 = vertices.first
		(2...vertices.length).each do |i|
			p2 = vertices[i-1]
			p3 = vertices[i]
			area += ((p1.x*(p2.y - p3.y) + p2.x*(p3.y-p1.y) + p3.x*(p1.y - p2.y))/2).abs
		end
	end
end