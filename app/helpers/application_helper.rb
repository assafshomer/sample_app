module ApplicationHelper

	def full_title(page_title)
		base_title="Ruby on Rails Tutorial Sample App"		
		if page_title.blank?
			base_title
		else
			"#{base_title} | #{page_title}"
		end
	end

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
