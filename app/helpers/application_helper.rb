module ApplicationHelper

	def full_title(page_title)
		base_title="Ruby on Rails Tutorial Sample App"
		base_title.insert(0,'3000: ') if Rails.env.development?
		if page_title.blank?
			base_title
		else
			"#{base_title} | #{page_title}"
		end
	end
	
  def search(space_separated_terms, *field_names)
    sql_query=""
    search_terms=extract_minimal_search_terms(space_separated_terms.split)
    wrap_percent=search_terms.map {|term| "%#{term}%" } 
    field_names.each do |field|
      append_like=["#{field} LIKE ? "]*search_terms.size
      sql_query+=append_like.join(" OR ") + " OR "
    end
    sql_query=sql_query[0,sql_query.length-' OR '.length]
    [sql_query] + wrap_percent*field_names.size   
  end

	def extract_minimal_search_terms(search_array)
		search_array=search_array.compact.uniq
		search_array.each do |x|
			search_array.each do |y|
				search_array=search_array-([]<<y) if y.include?(x) and y!=x
			end
		end	
		search_array
	end  
	
end

# tne next three lines remove the last OR with array mech
# sql_array_long=sql.split
# sql_array_short=sql_array_long.pop
# sql=sql_array_short.join(' ')