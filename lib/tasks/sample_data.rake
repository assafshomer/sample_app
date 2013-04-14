namespace :db do
	desc "fill database with sample data"
	task populate: :environment do 
		make_users
		make_microposts
		make_relationships		
		make_messages		
	end

	def make_users
		assaf=User.create!(name: 										"Assaf shomer", 
									email: 									"assafshomer@gmail.com" ,
									password: 							"foobar",
									password_confirmation: 	"foobar")
		assaf.toggle!(:admin)
		99.times do |n|
			name=Faker::Name.name
			email="example-#{n+2}@example.org"
			password="password"
			User.create!(name: name, 
										email: email, 
										password: password,
										password_confirmation: password)
		end
	end

	def make_microposts
		users=User.all
		users.each do |user|
			number_of_posts=rand(1..50)			
			number_of_posts.times do |blurb|
				number_of_lines=rand(1..15)
				hours_created_ago=rand(1..100)
				blurb=Faker::Lorem.sentence(number_of_lines)[1..140]
				blurb="short post" unless blurb.length>5
				micropost=user.microposts.create!(content: blurb)	
				micropost.created_at=hours_created_ago.hour.ago		
				micropost.save	
			end
		end
	end

	def make_messages
		users=User.first(50)
		users.each do |user|
			number_of_messages=rand(1..5)
			followers=user.followers.first(5)
			followers.each do |follower|
				number_of_messages.times do |blurb|
					number_of_lines=rand(1..15)
					hours_created_ago=rand(1..100)
					blurb=Faker::Lorem.sentence(number_of_lines)[1..140]
					blurb="hello #{user.name}" unless blurb.length>5
					message=user.messages.create!(content: blurb, recipient_id: follower.id)
					message.created_at=hours_created_ago.hour.ago
					message.save
				end				
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
			number_of_followed=rand(50)
			followed_users=users.sample(number_of_followed)
			followed_users.each do |followed_user|
				user.follow!(followed_user) unless followed_user==user
			end
		end
	end



end