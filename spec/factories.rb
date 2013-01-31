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
		sequence(:email) {|n| "Person_#{n}@example.edu"}
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

end