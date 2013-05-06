module SearchHelper

	def generate_sql(space_separated_terms, *field_names)
		sql_query=""
		search_terms=extract_minimal_search_terms(space_separated_terms.split)
		wrap_percent=search_terms.map {|term| "%#{term}%" } 
		field_names.each do |field|
			if Rails.configuration.database_configuration[Rails.env]["adapter"] =~ /postgresql/
				append_like=["#{field} ILIKE ? "]*search_terms.size	
			else
				append_like=["#{field} LIKE ? "]*search_terms.size
			end      
			sql_query+=append_like.join(" OR ") + " OR "
		end
		sql_query=sql_query[0,sql_query.length-' OR '.length]
		[sql_query] + wrap_percent*field_names.size   
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
					
end
