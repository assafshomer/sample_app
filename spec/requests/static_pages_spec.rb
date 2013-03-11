require 'spec_helper'

describe "Static pages" do

  subject { page }
  
  shared_examples_for "all static pages" do 
    it { should have_selector('h1',    text: heading) }
    it { should have_selector('title', text: full_title(page_title)) }
  end

  describe "Home page" do
    before { visit root_path }
    let(:page_title) {''}
    let(:heading) {'Sample App'}
    it_should_behave_like "all static pages"
    it { should_not have_selector 'title', text: '| Home' }

    describe "for non signed in users should show the signup button" do
      it { should have_selector('h1', text: /Welcome to the sample app/i) }  
      it { should have_link('Sign up now!') }
    end

    describe "for signed in users" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
        test_sign_in user
        visit root_path
      end
      it "should render the user's feed" do
        user.feed.each do |item|
          page.should have_selector("li##{item.id}",text: item.content)
          page.should have_link('delete', href: micropost_path(item))
        end  
      end
      it "should have a link to the profile page" do
        page.should have_link('view my profile', href: user_path(user))
      end
      it "should show a micropost count" do
        page.should have_selector('span', text: "#{user.microposts.count} microposts")
      end

      describe "following/followers counts" do
        let(:other_user) { FactoryGirl.create(:user) }
        before(:each) do
          other_user.follow!(user)
          visit root_path
        end
        it { should have_link('1 followers', href: followers_user_path(user)) }
        it { should have_link('0 following', href: following_user_path(user)) }
      end
    end

    describe "microposts of other users" do
      let(:user) { FactoryGirl.create(:user) }
      let(:other_user) { FactoryGirl.create(:user) }      
      before(:each) do
        FactoryGirl.create(:micropost, user: other_user, content: "foobaz")
        test_sign_in user 
        visit user_path(other_user)               
      end 
      it { page.should have_content(other_user.name) }
      it { page.should have_selector('h3', text: "Microposts #{other_user.microposts.count}") }
      it { page.should have_link('reply') } 
    end

  end

  describe "Help page" do
    before { visit help_path }
    let(:page_title) {'Help'}
    let(:heading) {'Help'}
    it_should_behave_like "all static pages"
  end

  describe "About page" do
    before { visit about_path }
    let(:page_title) {'About Us'}
    let(:heading) {'About'}
    it_should_behave_like "all static pages"
  end

  describe "Contact page" do
    before { visit contact_path }
    let(:page_title) {'Contact'}
    let(:heading) {'Contact'}
    it_should_behave_like "all static pages"
  end 

  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    page.should have_selector 'title', text: full_title('About Us')
    page.should have_selector('img.gravatar#assaf')
    click_link "Help"
    page.should have_selector 'title', text: full_title('Help')
    click_link "Contact"
    page.should have_selector 'title', text: full_title('Contact')
    click_link "Home"
    page.should have_selector 'h1', text: 'Welcome to the Sample App'
    click_link "Sign up now!"
    page.should have_selector 'title', text: full_title('Sign Up')
    click_link "sample app"
    page.should have_selector 'h2', text: 'This is the home page of my sample application'
  end
end