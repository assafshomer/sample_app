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

		describe "creating relationships" do
			let(:user) { FactoryGirl.create(:user) }
			let(:followed_user) { FactoryGirl.create(:user) }
			before { controller.sign_in(user) }	
			describe "using POST 'create'" do		
				it "should send a notification email" do
					lambda do
						post :create, relationship: {followed_id: followed_user.id}						
					end.should change(Mailer.deliveries, :count).by(1)
				end			
				it "should create the relationship" do
					lambda do
						post :create, relationship: {followed_id: followed_user.id}
					end.should change(Relationship, :count).by(1)
				end
			end	
			describe "with Ajax" do
				it "should send a notification email" do
					lambda do
						xhr :post, :create, relationship: { followed_id: followed_user.id }						
					end.should change(Mailer.deliveries, :count).by(1)
				end
		   	it "should increment the Relationship count" do
		      expect do
		        xhr :post, :create, relationship: { followed_id: followed_user.id }
		      end.to change(Relationship, :count).by(1)
		    end
		    it "should respond with success" do
		      xhr :post, :create, relationship: { followed_id: followed_user.id }
		      response.should be_success
		    end

		  end
		end
	
		describe "destroying a relationship" do
			let(:user) { FactoryGirl.create(:user) }
			let(:followed_user) { FactoryGirl.create(:user) }
			before(:each) do
			  controller.sign_in(user)
			  user.follow!(followed_user)
			  @relationship=user.relationships.find_by_followed_id(followed_user.id)
			end
			it "should send a notification email" do
				lambda do
					delete :destroy, id: @relationship.id					
				end.should change(Mailer.deliveries, :count).by(1)
			end
			describe "using delete 'destroy'" do		
				it "should destroy the relationship" do
					lambda do
						delete :destroy, id: @relationship.id
					end.should change(Relationship, :count).by(-1)
				end
			end
			describe "with Ajax" do
			it "should send a notification email" do
				lambda do
					xhr :delete, :destroy, id: @relationship.id					
				end.should change(Mailer.deliveries, :count).by(1)
			end			
	    it "should decrement the Relationship count" do
	      expect do
	        xhr :delete, :destroy, id: @relationship.id
	      end.to change(Relationship, :count).by(-1)
	    end

	    it "should respond with success" do
	      xhr :delete, :destroy, id: @relationship.id
	      response.should be_success
	    end
	  end
	end


end