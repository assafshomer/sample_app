require 'spec_helper'

describe MessagesController do
	
	describe "access control when not logged in" do
		it "should reject posting to 'create'" do			
			post :create
			response.should redirect_to(signin_path)
		end	
	end


end