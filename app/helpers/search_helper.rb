module SearchHelper

	def generate_sql(space_separated_terms, space_separated_field_names, class_name)
		sql_query=""
		search_terms=extract_minimal_search_terms(space_separated_terms[0,40].split)
		like_terms=wrap_with_percent search_terms
		field_names=extract_legal_fields(space_separated_field_names, class_name)
		field_names.each do |field|
			if Rails.configuration.database_configuration[Rails.env]["adapter"] =~ /postgresql/
				append_like=["#{field} ILIKE ? "]*search_terms.size	
			else
				append_like=["#{field} LIKE ? "]*search_terms.size
			end      
			sql_query+=append_like.join(" OR ") + " OR "
		end
		sql_query=sql_query[0,sql_query.length-' OR '.length]
		[sql_query] + like_terms*field_names.size   
	end

	def extract_minimal_search_terms(search_array)
		search_array=search_array.compact.map(&:downcase).uniq
		search_array.each do |x|
			search_array.each do |y|
				search_array=search_array-([]<<y) if y.include?(x) and y!=x
			end
		end	
		search_array
	end  

	def extract_legal_fields(space_separated_field_names, class_name)
		if class_name 	
			result=[]
			name_array=space_separated_field_names[0,40].split
			name_array.each do |candidate|
				result << candidate if class_name && class_name.new.attributes.keys.include?(candidate)
			end
			result
		else
			space_separated_field_names[0,40].split
		end
	end

	def wrap_with_percent(string_array)
		string_array.map {|term| "%#{term}%" }
	end
					
end
