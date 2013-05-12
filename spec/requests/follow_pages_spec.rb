require 'spec_helper'

describe "following/followers" do
  subject { page }
  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }
  before { user.follow!(other_user) }

  describe "following page for signed in user" do
   before(:each) do
     test_sign_in user
     visit following_user_path(user)
   end
    it { should have_selector('title', text: 'Following') }
    it { should have_selector('h3',text: 'Following') }
    it { should have_link(other_user.name, href: user_path(other_user)) }
    describe "search following" do
      it { should have_selector('input#search') }          
      it { should have_selector('input#users_search_button', value: "Search") }
      describe 'should not filter on empty search' do
        before(:all) do
          30.times do
            user.follow!(FactoryGirl.create(:user))
          end 
        end
        after(:all) { User.delete_all }
        before { click_button 'Search' }
        it { should have_selector('div.pagination') }          
      end
      describe "should return to the followers page after clicking the search button" do
        before do
          fill_in 'search', with: 'supercalifrajilisticexpialidocious'
          click_button 'Search'
        end
        it { should have_selector('title', text: 'Following') }
        it { should have_selector('input#search') }          
        it { should have_selector('input#users_search_button', value: "Search") }
      end
      describe "should search following correctly" do
        let!(:marlon) { FactoryGirl.create(:user, name: 'Marlon Brando', email: 'marlon@holliwood.com') }
        let!(:barack) { FactoryGirl.create(:user, name: 'Barack Obama', email: 'barack@president.gov') }         
        before do
          barack.follow!(marlon)
          click_link 'Sign out'
          test_sign_in barack
          visit following_user_path(barack)
          fill_in 'search', with: 'marlo a.x'
          click_button 'Search'
        end
        it "should find marlon" do
          page.should have_selector('li', text: marlon.name)
          page.should have_link 'Email' , href: "mailto:#{marlon.email}"
          page.should have_link(marlon.name, href: user_path(marlon.id))            
        end
        it "should not find barack" do
          page.should_not have_selector('li', text: barack.name)
          page.should_not have_link 'Email' , href: "mailto:#{barack.email}"                          
        end            
      end        
    end        
  end

  describe "followers page for signed in user" do
   before(:each) do
     test_sign_in other_user
     visit followers_user_path(other_user)
   end
    it { should have_selector('title', text: 'Followers') }
    it { should have_selector('h3',text: 'Followers') }
    it { should have_link(user.name, href: user_path(user)) }
    describe "search followers" do
      it { should have_selector('input#search') }          
      it { should have_selector('input#users_search_button', value: "Search") }
      describe 'should not filter on empty search' do
        before(:all) do
          30.times do
            FactoryGirl.create(:user).follow!(other_user)
          end 
        end
        after(:all) { User.delete_all }
        before { click_button 'Search' }
        it { should have_selector('div.pagination') }          
      end
      describe "should return to the followers page after clicking the search button" do
        before do
          fill_in 'search', with: 'supercalifrajilisticexpialidocious'
          click_button 'Search'
        end
        it { should have_selector('title', text: 'Followers') }
        it { should have_selector('input#search') }          
        it { should have_selector('input#users_search_button', value: "Search") }
      end
      describe "should search followers correctly" do
        let!(:marlon) { FactoryGirl.create(:user, name: 'Marlon Brando', email: 'marlon@holliwood.com') }
        let!(:barack) { FactoryGirl.create(:user, name: 'Barack Obama', email: 'barack@president.gov') }         
        before do
          marlon.follow!(barack)
          click_link 'Sign out'
          test_sign_in barack
          visit followers_user_path(barack)
          fill_in 'search', with: 'marlo a.x'
          click_button 'Search'
        end
        it "should find marlon" do
          page.should have_selector('li', text: marlon.name)
          page.should have_link 'Email' , href: "mailto:#{marlon.email}"
          page.should have_link(marlon.name, href: user_path(marlon.id))            
        end
        it "should not find barack" do
          page.should_not have_selector('li', text: barack.name)
          page.should_not have_link 'Email' , href: "mailto:#{barack.email}"                          
        end            
      end        
    end        
  end                 
end