# FactoryGirl.define do
#   factory :user do
#     name     "Michael Hartl"
#     email    "michael@example.com"
#     password "foobar"
#     password_confirmation "foobar"
#   end
# end

FactoryGirl.define do 
	factory :user do
		sequence(:name) {|n| "Person #{n}"}
		sequence(:email) {|n| "Person_#{n}_#{Random.rand(0..999)}@example.edu"}
		password "foobar"
		password_confirmation "foobar"
	end

	factory :admin do
		admin true
	end	

	factory :micropost do
		content "Lorem"
		user
	end

	factory :message do
		content "message"
		sender User.first
		recipient User.last				
	end

end