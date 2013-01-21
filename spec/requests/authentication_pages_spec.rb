require 'spec_helper'

describe "Authentication" do 
  subject {page}
 
  describe "signing in" do
  	before { visit signin_path }  

  	it { should have_selector('h1', text: 'Sign in') }
  	it { should have_selector('title', text: 'Sign in') }  

  	describe "with invalid info" do
  		before { click_button "Sign in" }

  		it { should have_selector('title', text: 'Sign in')}
  		it { should have_selector('div.alert.alert-error', text: 'Invalid') }	

  		describe "after visiting another page" do
  			before { click_link "Home" }
  			it { should_not have_selector('div.alert.alert-error') }  			
  		end
  	end

  	describe "with valid information" do
  		let(:user) { FactoryGirl.create(:user) }

      before { test_sign_in user }     

      it { should have_selector('title', text: user.name) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) } 	 
    end   
  end

  describe "authorization" do
    describe "for non signed in users" do
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
    end

    describe "for signed in user" do
       let(:user) { FactoryGirl.create(:user) }
       let(:wrong_user) { FactoryGirl.create(:user, name: "Wrong User", email: "wrong@example.com") }
        
      before { test_sign_in user }      
      
      describe "attempting to edit own settings" do
        before { visit edit_user_path(user) }
        it { should have_selector('title', text: full_title('Edit user')) }
      end

      # describe "attempting to put to the 'update' action of correct user" do
      #   before { put user_path(user) }
      #   specify { response.should_not redirect_to(signin_path)}        
      # end

      describe "attempting to edit another user's settings via the interface" do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_selector 'title', text: full_title('Edit user') }        
      end

      # describe "attempting to put to the 'update' action of another user" do
      #   before { put user_path(wrong_user) }
      #   specify { response.should redirect_to(root_path) }
      # end 
            
    end      
  end

end


