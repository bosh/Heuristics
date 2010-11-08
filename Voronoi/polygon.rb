class Polygon
	attr_accessor :center, :vertices
	def initialize(center, lines)
		@center = center
		#TODO create polygon from set of lines
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