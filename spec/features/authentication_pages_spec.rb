require 'spec_helper'

describe "Authentication" do 
  subject {page}
 
  describe "signing in" do
  	before { visit signin_path }  

  	it { should have_selector('h1', text: 'Sign in') }
  	it { should have_title 'Sign in' }  
    it { should have_selector('input#session_email') }
    it { should have_selector('input#session_password') }
    it { should have_selector('input#session_remember_me') }    
    it { should have_link('forgot?', href: reset_password_path) }

    describe "forgot password link" do
      before { click_link 'forgot?' }  
      it { should have_title 'Reset password' }
      it { should have_selector('input#password_reset_email') }
      it { should have_selector('input#send_reset_password_email') }
    end

  	describe "with invalid info" do
  		before { click_button "Sign in" }

  		it { should have_title 'Sign in' }
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

      it { should have_title user.name }

      it { should have_link('Users', href: users_path) }
      it { should have_link('Messages', href: messages_path) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) } 
      describe "attempting to hit the signin path while signed in should redirect Home" do
        before { visit signin_path }
        it { should have_selector('h1', text: /#{user.name}/i) }
      end

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
        it { should have_title 'Sign in' }
        it { should have_selector 'div.alert.alert-notice', text: 'Please sign in' }                
      end 

      describe "visiting the users index" do
        before { visit users_path }
        it { should have_title 'Sign in' }        
      end

      describe "visiting the messages index" do
        before { visit messages_path }
        it { should have_title 'Sign in' }        
      end
      
      describe "visiting the followers page" do
        before { visit followers_user_path(1) }
        it { should have_title 'Sign in' }
      end      

      describe "visiting the following page" do
         before { visit following_user_path(1) }
         it { should have_title 'Sign in' }
       end 
    end        
  end
end


