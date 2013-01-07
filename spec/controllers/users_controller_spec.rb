require 'spec_helper'

describe UsersController do 

	render_views

  describe "Get new" do 
		it "should be successful" do
			get :new
			response.should be_success
		end		
	end

	it "should have the right title" do
		visit signup_path
		page.should have_selector('title',text: "Sign Up")
	end 

end
