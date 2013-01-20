require 'spec_helper'
require '/home/assaf/rails_projects/sample_app/spec/support/test_utilities.rb'
include TestUtilities

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

      before { sign_in user }
  		# before do
  		#   fill_in "Email",		with: user.email 
  		#   fill_in "Password", with: user.password 
  		#   click_button 'Sign in'
  		# end

  		it { should have_selector('title', text: user.name) }
  		it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Settings', href: edit_user_path(user)) }
  		it { should have_link('Sign out', href: signout_path) }
  		it { should_not have_link('Sign in', href: signin_path) }
  		it { should have_selector('div.alert.alert-success', content: "Welcome back") }

      describe "followd by signing out" do
        before { click_link 'Sign out' }
        it { should have_link 'Sign in', href: signin_path }
        it { should_not have_link 'Sign out', href: signout_path }
        it { should_not have_link 'Settings' }
        it { should_not have_link 'Account' }
        it { should_not have_selector 'ul.dropdown-menu' }
      end
  	end  
  	 
  end

  
end
