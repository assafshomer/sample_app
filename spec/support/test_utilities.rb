module TestUtilities
	
	def reverse_string_case(string)
		reversed=string
		i=0
		string.each_char do |char|		
			if char==char.upcase
				reversed[i]=char.downcase
			else
				reversed[i]=char.upcase
			end
			i+=1
		end
		reversed
	end	

end