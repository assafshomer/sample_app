namespace :db do
	desc "fill database with sample data"
	task populate: :environment do 
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
end