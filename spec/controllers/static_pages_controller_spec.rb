require 'spec_helper'

describe StaticPagesController do
render_views
let(:base_title) { "Ruby on Rails Tutorial Sample App" }

  describe "GET 'home'" do
    it "returns http success" do
      get 'home'
      response.should be_success    
    end 

    it "should have the content 'Sample App'" do
      visit root_path
      page.should have_content('Sample App')
    end 

    it "should have the correct title" do
      visit root_path
      page.should have_selector('title', 
                                text: "#{base_title}")
    end  

    it "should not end with pipe home" do
      visit root_path
      page.should_not have_selector('title', 
                                text: "| Home")
    end  
   

  end

  describe "GET 'help'" do
    it "returns http success" do
      get 'help'
      response.should be_success
    end 

    it "should have the content 'Help'" do
      visit help_path
      page.should have_content('help')
    end

    it "should have the correct title" do
      visit help_path
      page.should have_selector('title', 
                                text: "#{base_title} | Help")
    end 
  end 

  describe "GET 'about'" do

    it "returns http success" do
      get 'about'
      response.should be_success
    end

    it "should have the correct title" do
      visit about_path
      page.should have_selector('title', 
                                text: "#{base_title} | About Us")
    end 

  end

  describe "GET 'contact'" do

      it "returns http success" do
        get 'contact'
        response.should be_success
      end

      it "should have the correct title" do
        visit contact_path
        page.should have_selector('title', 
                                  text: "#{base_title} | Contact")
      end 

    end
end
