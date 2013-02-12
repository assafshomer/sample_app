require 'spec_helper'

describe RelationshipsController do
	describe "access control for non-signed in users" do
		it "should denty access to post 'create' " do
			post :create
			response.should redirect_to(signin_path)
		end 		
		it "should denty access to delete 'destroy' " do
			delete :destroy, id: 1
			response.should redirect_to(signin_path)
		end 
	end

	describe "creating the relationship using POST 'create'" do
		let(:user) { FactoryGirl.create(:user) }
		let(:followed_user) { FactoryGirl.create(:user) }
		before { controller.sign_in(user) }		
		it "should create the relationship" do
			lambda do
				post :create, relationship: {followed_id: followed_user.id}
			end.should change(Relationship, :count).by(1)
		end
	end
	describe "destroying the relationship using delete 'destroy'" do
		let(:user) { FactoryGirl.create(:user) }
		let(:followed_user) { FactoryGirl.create(:user) }
		before(:each) do
		  controller.sign_in(user)
		  user.follow!(followed_user)
		  @relationship=user.relationships.find_by_followed_id(followed_user.id)
		end
		it "should destroy the relationship" do
			lambda do
				delete :destroy, id: @relationship.id
			end.should change(Relationship, :count).by(-1)
		end
	end
end