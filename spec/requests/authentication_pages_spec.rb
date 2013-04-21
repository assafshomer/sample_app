require 'spec_helper'

describe "Authentication" do 
  subject {page}
 
  describe "signing in" do
  	before { visit signin_path }  

  	it { should have_selector('h1', text: 'Sign in') }
  	it { should have_selector('title', text: 'Sign in') }  
    it { should have_selector('input#session_email') }
    it { should have_selector('input#session_password') }
    it { should have_selector('input#session_remember_me') }
    it { should have_link('forgot?') }

  	describe "with invalid info" do
  		before { click_button "Sign in" }

  		it { should have_selector('title', text: 'Sign in')}
  		it { should have_selector('div.alert.alert-error', text: 'Invalid') }	
      it { should_not have_link('Users', href: users_path) }
      it { should_not have_link('Messages', href: messages_path) }
      it { should_not have_link('Profile') }
      it { should_not have_link('Settings') }
      it { should_not have_link('Sign out', href: signout_path) }

  		describe "after visiting another page" do
  			before { click_link "Home" }
  			it { should_not have_selector('div.alert.alert-error') }  			
  		end      
  	end

  	describe "with valid information" do
  		let(:user) { FactoryGirl.create(:user) }

      before { test_sign_in user }     

      it { should have_selector('title', text: user.name) }

      it { should have_link('Users', href: users_path) }
      it { should have_link('Messages', href: messages_path) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) } 

      # describe "cookies" do
      #   before { get user_path(user) }         
      #   specify {response.headers["Set-Cookie"].should =~ /remember_token/}        
      # end       
    end   
  end



  describe "authorization" do
    describe "for users that are not signed in" do
      let(:user) { FactoryGirl.create(:user) }

      describe "visiting the edit page" do
        before { visit edit_user_path(user) }
        it { should have_selector 'title', text: 'Sign in' }
        it { should have_selector 'div.alert.alert-notice', text: 'Please sign in' }                
      end 

      describe "submitting to the update action" do
        before { put user_path(user) }
        specify { response.should redirect_to(signin_path) }        
      end 

      describe "visiting the users index" do
        before { visit users_path }
        it { should have_selector('title',text: 'Sign in') }        
      end

      describe "visiting the messages index" do
        before { visit messages_path }
        it { should have_selector('title',text: 'Sign in') }        
      end

      describe "in the Microposts controller" do

        describe "submitting to the create action" do
          before { post microposts_path }
          specify { response.should redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { response.should redirect_to(signin_path) }
        end
      end 

      describe "in the Relationships controller" do
        describe "submitting to the create action" do
          before { post relationships_path }
          specify { response.should redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do 
          before { delete relationship_path(1) }
          specify { response.should redirect_to(signin_path) }
        end
      end 

      describe "in the Messages controller" do
        describe "submitting to the create action" do
          before { post messages_path }
          specify { response.should redirect_to(signin_path) }
        end     
      end 

      describe "getting the followers page" do
        before { get followers_user_path(1) }
        specify {response.should redirect_to(signin_path)}
      end  

      describe "visiting the followers page" do
        before { visit followers_user_path(1) }
        it { should have_selector('title', text: 'Sign in') }
      end

      describe "getting the following page" do
        before { get following_user_path(1) }
        specify {response.should redirect_to(signin_path)}
      end 

      describe "visiting the following page" do
         before { visit following_user_path(1) }
         it { should have_selector('title', text: 'Sign in') }
       end 
    end        
  end
end


