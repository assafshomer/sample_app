require 'spec_helper'

describe "Search Microposts" do
	subject { page }
	let!(:user) { FactoryGirl.create(:user, active: true, name: 'Neil Young') }
	let!(:leader) { FactoryGirl.create(:user, name: 'Bruce Springsteen') }
	let!(:other_user) { FactoryGirl.create(:user) }
	before(:all) do
		20.times {user.microposts.create!(content: Faker::Lorem.sentence(10))}	
		user.microposts.create(content: "Hey hey my my, Rock & Roll may never die")					
		user.microposts.create(content: "But his laughing lady's loving ain't the kind he can keep")
		user.follow!(leader)
		leader.microposts.create(content: "my my hey hey rocknroll is here to stay")
		other_user.microposts.create(content: "there's more to the picture than meets the eye, hey hey my my")
	end
	after(:all) {User.delete_all}
	describe "homepage" do
		before do
			test_sign_in user 
			visit root_path 			
		end
		describe "search field and buttons" do
			it { should have_selector('input#search') }          
	    it { should have_selector('input#mp_search_button') }
	    it { should have_selector('input#mp_clear_search_button') }
		end	
		describe "should not filter on empty search" do
			before { click_button 'Search' }
			it { should have_selector('div.pagination') }  
		end	
		describe "should not disappear or paginate on search with no results" do
			before do 
				fill_in 'search', with: 'supercalifragilisticexpialidocious'
				click_button 'Search'
			end
			it { should have_selector('input#search') }          
	    it { should have_selector('input#mp_search_button') }
	    it { should have_selector('input#mp_clear_search_button') }
	    it { should_not have_selector('div.pagination') }
		end				
		describe "should search feed by content" do
			before do
				fill_in 'search', with: "my my"		  
				click_button 'Search'
			end		
			it { should have_content('Rock & Roll') }
			it { should_not have_content('laughing') }
			it { should have_content('here to stay') }
			it { should_not have_content('pitcture') }
		end
		describe "should search feed by user name" do
			before do
				fill_in 'search', with: "Neil"		  
				click_button 'Search'
			end		
			it { should have_content('Rock & Roll') }
			it { should have_content('laughing') }
			it { should_not have_content('here to stay') }
			it { should_not have_content('picture') }
		end									
	end

	describe "user profile" do
		before do 
			test_sign_in user
			visit user_path(user)
		end				
		describe "search field and buttons" do	
			it { should have_selector('input#search') }          
	    it { should have_selector('input#mp_search_button') }
	    it { should have_selector('input#mp_clear_search_button') }
		end
		describe "should not filter on empty search" do
			before { click_button 'Search' }
			it { should have_selector('div.pagination') }  
		end
		describe "should not disappear or paginate on search with no results" do
			before do 
				fill_in 'search', with: 'supercalifragilisticexpialidocious'
				click_button 'Search'
			end
			it { should have_selector('input#search') }          
	    it { should have_selector('input#mp_search_button') }
	    it { should have_selector('input#mp_clear_search_button') }
	    it { should_not have_selector('div.pagination') }
		end			
		describe "should search microposts by content" do
			before do
				fill_in 'search', with: "my my"		  
				click_button 'Search'
			end		
			it { should have_content('Rock & Roll') }
			it { should_not have_content('laughing') }
		end	
	end

end
