namespace :db do
	desc "fill database with sample data"
	task populate: :environment do 
		make_users
		make_microposts
		make_relationships
		
	end

	def make_users
		assaf=User.create!(name: 										"Assaf shomer", 
									email: 									"assafshomer@gmail.com" ,
									password: 							"foobar",
									password_confirmation: 	"foobar")
		assaf.toggle!(:admin)
		99.times do |n|
			name=Faker::Name.name
			email="example-#{n+1}@example.org"
			password="password"
			User.create!(name: name, 
										email: email, 
										password: password,
										password_confirmation: password)
		end
	end

	def make_microposts
		users=User.all(limit: 6)
		users.each do |user|
			50.times do |blurb|
				blurb=Faker::Lorem.sentence(5)
				user.microposts.create!(content: blurb)				
			end
		end
	end

	# def make_relationships
	# 	user=User.first
	# 	followers_of_user=User.all[1..25]
	# 	followed_by_user=User.all[10..20]
	# 	followers_of_user.each {|follower| follower.follow!(user)}	
	# 	followed_by_user.each {|followed| user.follow!(followed)}	
	# end

	def make_relationships
		users=User.all
		users.each do |user|
			number_of_followed=rand(Math::sqrt(User.count))
			followed_users=users.sample(number_of_followed)
			followed_users.each do |followed_user|
				user.follow!(followed_user)
			end
		end
	end

end