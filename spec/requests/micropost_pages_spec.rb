require 'spec_helper'

describe "MicropostPages" do
	subject { page }

	let(:user) { FactoryGirl.create(:user) }
	before(:each) do
	  test_sign_in user
	  visit root_path
	end	

	describe "empty micropost text area" do
		it { should have_selector('textarea#micropost_content', text: "") }		
	end

	describe "micropost form should have a 'Post' button" do
		it { should have_selector('input#Post_button') }
		
	end

	describe "micropost creation" do		

		describe "with invalid data" do
			it "should not create a new micropost" do
				expect {click_button 'Post'}.not_to change(Micropost, :count)
			end
			describe "error message" do
				before { click_button 'Post' }
				it { should have_content('error') }
				it { should have_selector('div.alert.alert-error') }
			end
		end

		describe "with valid info" do
			before { fill_in "micropost_content", with: "Lorem ipsum" }
			it "should create a new micropost" do
				expect {click_button 'Post'}.to change(Micropost, :count).by(1)
			end		

			describe "should redirect to the home page" do
				before do
					# fill_in "micropost_content", with: "Lorem ipsum"
					click_button 'Post' 
				end 
				it { should have_selector('div.alert.alert-success',
					text: "published successfully" ) }
			end	
		end	
	end	

	describe "micropost deletion" do
		let!(:mp) { FactoryGirl.create(:micropost, user: user, content: 'Lorem') }
		before {visit root_path}
		it "should remove the micropost" do
			expect {click_link('delete')}.to change(Micropost, :count).by(-1)			
		end		 
	end 

	describe "clicking the reply link" do
		let!(:new_user) { FactoryGirl.create(:user) }
		let!(:follower_of_user) { FactoryGirl.create(:user) }
		let!(:new_user_post) { FactoryGirl.create(:micropost, user: new_user, content: "post by new user") }
		before(:each) do
			follower_of_user.follow!(user)
			visit user_path(new_user)
			click_link('reply')		  
		end
		it "should redirect to the logged in user homepage" do			
			page.should have_selector('h1', text: user.name)
			page.should have_link('view my profile', href: user_path(user))
		end

		it "should begin the post with @ followed by the replied to user name" do
			page.should have_selector('textarea', text: "@#{new_user.name}")			
		end

		it "should show a Reply button instead of a post button" do
			page.should have_selector('input#Reply_button')
		end

		describe "and replying to a micropost" do
			
			describe "should stamp the micropost table with the correct reply_to id" do
				before { click_button 'Reply' }
				specify {user.microposts.first.in_reply_to.should == new_user.id}
			end	

			it "should appear on the replied to user's feed" do
				expect {click_button 'Reply'}.to change(new_user.feed, :count).by(1)			
			end

			it "should appear on the logged in user's feed" do
				expect {click_button 'Reply'}.to change(user.feed, :count).by(1)
			end
			
			it "should not appear on any other of the replyer followers' feed" do
				expect {click_button 'Reply'}.not_to change(follower_of_user.feed, :count)
			end
		end 
	end


end
