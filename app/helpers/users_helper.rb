module UsersHelper
	def gravatar_for(user, options={size: 50})
		size = options[:size]
		gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}&d=identicon"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
	end

	def my_email
		"assafshomer@gmail.com"
	end

	def my_gravatar(options={size: 100})
		size = options[:size]
		gravatar_id = Digest::MD5::hexdigest(my_email)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: "Assaf Shomer", class: "gravatar", id: "assaf", title: "shoot me an email")
	end

end

