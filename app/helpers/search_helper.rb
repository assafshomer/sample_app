module SearchHelper

	def generate_LIKE_sql(space_separated_terms, space_separated_field_names, class_name)		
		search_terms=extract_minimal_search_terms(space_separated_terms)
		like_terms=wrap_with_percent(search_terms)
		field_names=extract_legal_fields(space_separated_field_names, class_name)
		sql_query=generate_LIKE_query(search_terms,field_names)
		[sql_query] + like_terms*field_names.size   
	end

	def generate_LIKE_query(search_terms_array,field_names_array)
		sql_query=""
		field_names_array.each do |field|
			if Rails.configuration.database_configuration[Rails.env]["adapter"] =~ /postgresql/
				append_like=["#{field} ILIKE ? "]*search_terms_array.size	
			else
				append_like=["#{field} LIKE ? "]*search_terms_array.size
		end      
			sql_query+=append_like.join(" OR ") + " OR "
		end
		sql_query=sql_query[0,sql_query.length-' OR '.length]		
	end

	def generate_search_microposts_sql(space_separated_search_terms,space_separated_field_names='content')
		search_terms_array=extract_minimal_search_terms(space_separated_search_terms)
		like_terms_array=wrap_with_percent(search_terms_array)
		field_names_array=extract_legal_fields(space_separated_field_names, Micropost)		
		sql=generate_LIKE_query(search_terms_array,field_names_array)	
		sql+=' OR user_id IN (?)'		
		([sql] + like_terms_array*field_names_array.size) << search_user_ids(space_separated_search_terms, 'name email') 
	end	


	def extract_minimal_search_terms(space_separated_terms)
		search_array=space_separated_terms[0,40].split
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
				result << candidate if class_name.new.attributes.keys.include?(candidate)
			end
			result
		else
			space_separated_field_names[0,40].split
		end
	end

	def wrap_with_percent(string_array)
		string_array.map {|term| "%#{term}%" }
	end
				
  def search_user_ids(space_separated_search_terms, space_separated_field_names)          
    users=User.where(generate_LIKE_sql(space_separated_search_terms,space_separated_field_names, User))
    user_ids=users.each.map(&:id)
  end
  def get_microposts_by_user_id(array_of_ids)
  	Micropost.where('user_id IN (?)', array_of_ids)  	
  end
end
