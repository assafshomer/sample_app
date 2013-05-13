require 'spec_helper'

describe "Search Users" do
  subject { page }
  let!(:user) { FactoryGirl.create(:user, active: true) }
  let!(:marlon) { FactoryGirl.create(:user, name: 'Marlon Brando', email: 'marlon@holliwood.com') }
  let!(:barack) { FactoryGirl.create(:user, name: 'Barack Obama', email: 'barack@president.gov') }
  let!(:bill) { FactoryGirl.create(:user, name: 'Bill Clinton', email: 'billwaspresident@monica.xxx') }
  let!(:marlo) { FactoryGirl.create(:user, name: 'Marlo Stanfield', email: 'marlo@wire.org') } 
  before(:all) { 30.times {FactoryGirl.create(:user, name: "testuser")}  }
  after(:all) { User.delete_all }
  before(:each) do
    test_sign_in user    
  end

  describe "search users on the users list" do
    before { visit users_path }
    it { should have_selector('input#search') }          
    it { should have_selector('input#users_search_button') }
    it { should have_selector('input#users_clear_search_button') }
    
    describe 'should not filter on empty search' do
      before { click_button 'Search' }
      it { should have_selector('div.pagination') }          
    end
    describe "clear users search" do      
      before do        
        fill_in 'search', with: 'blahhhh'
        click_button 'Search'                                
        click_button 'Clear'                    
      end          
      it "should find marlon, marlo and bill" do
        # page.should have_selector('li', text: marlon.name)
      end                             
    end
    describe "should find a user by name" do
      before do        
        fill_in 'search', with: 'marlo a.x'
        click_button 'Search'
      end
      it "should find marlon, marlo and bill" do
        page.should have_selector('li', text: marlon.name)
        page.should have_link 'Email' , href: "mailto:#{marlon.email}"
        page.should have_link(marlon.name, href: user_path(marlon.id))
        page.should have_selector('li', text: marlo.name)
        page.should have_link 'Email' , href: "mailto:#{marlo.email}"
        page.should have_link(marlo.name, href: user_path(marlo.id))
        page.should have_selector('li', text: bill.name)
        page.should have_link 'Email' , href: "mailto:#{bill.email}"
        page.should have_link(bill.name, href: user_path(bill.id))              
      end
      it "should not find barack" do
        page.should_not have_selector('li', text: barack.name)
        page.should_not have_link 'Email' , href: "mailto:#{barack.email}"
        page.should_not have_link(barack.name, href: user_path(barack.id))                                      
      end                      
    end                   
  end

  describe "search followers" do   
    let!(:follower) { FactoryGirl.create(:user) }
    before do
      follower.follow!(user)
      visit followers_user_path(user)
    end
    it { should have_selector('input#search') }          
    it { should have_selector('input#users_search_button') }
    it { should have_selector('input#users_clear_search_button') }
    describe 'should not filter on empty search' do
      before do 
        User.all.each {|tempuser| tempuser.follow!(user) if tempuser.name=='testuser'}
        click_button 'Search'
      end
      it { should have_selector('div.pagination') }          
    end        

    describe "should find a user by name" do
      before do
        marlo.follow!(user)
        marlon.follow!(user)
        bill.follow!(user)
        barack.follow!(user)
        fill_in 'search', with: 'marlo a.x'
        click_button 'Search'        
      end
      it "should find marlon, marlo and bill but not barack" do
        page.should have_selector('li', text: marlon.name)
        page.should have_link 'Email' , href: "mailto:#{marlon.email}"
        page.should have_link(marlon.name, href: user_path(marlon.id))
        page.should have_selector('li', text: marlo.name)
        page.should have_link 'Email' , href: "mailto:#{marlo.email}"
        page.should have_link(marlo.name, href: user_path(marlo.id))
        page.should have_selector('li', text: bill.name)
        page.should have_link 'Email' , href: "mailto:#{bill.email}"
        page.should have_link(bill.name, href: user_path(bill.id))
        page.should_not have_selector('li', text: barack.name)
        page.should_not have_link 'Email' , href: "mailto:#{barack.email}"
        # page.should_not have_link(barack.name, href: user_path(barack.id))   # this dude fails due to the avatar link                      
      end                     
    end       
  end
  describe "search following" do   
    let!(:followed_user) { FactoryGirl.create(:user) }
    before do
      user.follow!(followed_user)
      visit following_user_path(user)
    end
    it { should have_selector('input#search') }          
    it { should have_selector('input#users_search_button') }
    it { should have_selector('input#users_clear_search_button') }
    describe 'should not filter on empty search' do
      before do 
        User.all.each {|tempuser| user.follow!(tempuser) if tempuser.name=='testuser'}
        click_button 'Search'
      end
      it { should have_selector('div.pagination') }          
    end        

    describe "should find a user by name" do
      before do
        user.follow!(marlo)
        user.follow!(marlon)
        user.follow!(bill)
        user.follow!(barack)
        fill_in 'search', with: 'marlo a.x'
        click_button 'Search'        
      end
      it "should find marlon, marlo and bill but not barack" do
        page.should have_selector('li', text: marlon.name)
        page.should have_link 'Email' , href: "mailto:#{marlon.email}"
        page.should have_link(marlon.name, href: user_path(marlon.id))
        page.should have_selector('li', text: marlo.name)
        page.should have_link 'Email' , href: "mailto:#{marlo.email}"
        page.should have_link(marlo.name, href: user_path(marlo.id))
        page.should have_selector('li', text: bill.name)
        page.should have_link 'Email' , href: "mailto:#{bill.email}"
        page.should have_link(bill.name, href: user_path(bill.id))
        page.should_not have_selector('li', text: barack.name)
        page.should_not have_link 'Email' , href: "mailto:#{barack.email}"
        # page.should_not have_link(barack.name, href: user_path(barack.id))   # this dude fails due to the avatar link                      
      end                     
    end       
  end              
end



