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
end