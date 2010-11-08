requirements = ['Point', 'Placement', 'Line', 'Bisector', 'Intersection', 'Polygon', 'Game', 'Player']
requirements.each do |req|
	require req
end

#TODO: Condensing into a single file to avoid requires/any issues with Energon
#new file = one_file_game.rb
#for each required filename
#  open filename.downcase << ".rb" as file
#  one_file_game.write file.contents
#end
#one_file_game << vore.rb