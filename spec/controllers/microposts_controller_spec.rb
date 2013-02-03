require 'spec_helper'

describe MicropostsController do
	render_views
	describe "access control when not logged in" do
		it "should reject posting to 'create'" do			
			post :create
			response.should redirect_to(signin_path)
		end
		it "should reject posting to 'delete'" do			
			delete :destroy, id: 1
			response.should redirect_to(signin_path)
		end		
	end

# for some reason this test doesn't pass when in here,  but does when in auth_pages_spec
	# describe "in the Microposts controller" do
 #    describe "submitting to the create action" do
 #      before { post microposts_path }
 #      specify { response.should redirect_to(signin_path) }
 #    end
 #  end   
end