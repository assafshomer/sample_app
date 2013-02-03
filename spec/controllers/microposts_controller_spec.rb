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

	# for some reason this test doesn't pass in here,  but does when in auth_pages_spec
	# describe "in the Microposts controller" do
 #    describe "submitting to the create action" do
 #      before { post microposts_path }
 #      specify { response.should redirect_to(signin_path) }
 #    end
 #  end   

	describe "micropost creation" do
		subject { page }

		let(:user) { FactoryGirl.create(:user) }		

		describe "with invalid data" do		
			before do
				controller.sign_in(user)
				visit root_path	
				@attr={content: ""}
			end	
			it "should not create a micropost" do
				lambda do
					post :create, micropost: @attr
				end.should_not change(Micropost, :count)				
			end
		end

		describe "with valid data" do		
			before do
				controller.sign_in(user)
				visit root_path	
				@attr={content: "Lorem ipsum dolor sit amet"}
			end	
			it "should create a micropost" do
				lambda do
					post :create, micropost: @attr
				end.should change(Micropost, :count).by(1)
			end
		end
	end


end