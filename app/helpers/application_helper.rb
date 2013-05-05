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
    sql=""
    like_terms=space_separated_terms.split.map {|term| "%#{term}%" } 
    field_names.each do |field|
      aux=["#{field} LIKE ? "]*like_terms.size
      sql+=aux.join(" OR ") + " OR "
    end
    sql=sql[0,sql.length-' OR '.length]   
    [sql] + like_terms*field_names.size   
  end
	
end
