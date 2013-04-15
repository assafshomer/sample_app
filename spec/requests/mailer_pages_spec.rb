require 'spec_helper'

describe "Mailer Pages" do
	subject {page}

	let!(:followed) { FactoryGirl.create(:user) }
	let!(:follower) { FactoryGirl.create(:user) }

	describe "unchecking the notification checkbox" do
		before(:each) do
		  test_sign_in(followed)
		  visit edit_user_path(followed)
      fill_in "Password",         with: followed.password
      fill_in "Confirmation", with: followed.password      
		  uncheck 'user_recieve_notifications'		
		  click_button 'Save changes'  		 
		end
		it "should change the notification bit for the followed user" do
			followed.reload.recieve_notifications.should be_false
		end
		describe "description" do
			before do
				test_sign_in(follower)
		  	visit user_path(followed)
			end
			it "should not send emails upon following" do
	      lambda do
	        click_button 'Follow'   
	        sleep (0.001).seconds
	        # Mailer.deliveries.should == ['blah']    
	      end.should_not change(Mailer.deliveries, :count)
			end
		end

	end
end
