require 'spec_helper'

describe "SearchMicroposts" do
	subject { page }
	let!(:user) { FactoryGirl.create(:user, active: true) }
	before(:all) do
		10.times {user.microposts.create!(content: Faker::Lorem.sentence(10))}						
	end
	after(:all) {User.delete_all}
	describe "homepage search field and buttons" do
		before do
			test_sign_in user 
			visit root_path 			
		end
		it { should have_selector('input#search') }          
    it { should have_selector('input#mp_search_button') }
    it { should have_selector('input#mp_clear_search_button') }
	end
	describe "user profile search field and buttons" do
		before do 
			test_sign_in user
			visit user_path(user)
		end			
		it { should have_selector('input#search') }          
    it { should have_selector('input#mp_search_button') }
    it { should have_selector('input#mp_clear_search_button') }
	end	
end
