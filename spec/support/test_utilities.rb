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


	def fake_address
		size=rand(3..6)			
		prefix=('a'..'z').to_a.shuffle[0..size].join
		suffix=('a'..'z').to_a.shuffle[0..size].join
		format=('a'..'z').to_a.shuffle[0..2].join
		"#{prefix}@#{suffix}.#{format}"				
	end

	def fake_subject
		Faker::Lorem.sentence(1)
	end

	def fake_content
		Faker::Lorem.sentence(5)		
	end

	def signup_title
		"Welcome to my Twitter clone"
	end

end