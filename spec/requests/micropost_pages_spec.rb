require 'spec_helper'

describe "MicropostPages" do
	subject { page }

	let(:user) { FactoryGirl.create(:user) }

	before { test_sign_in user }

	describe "micropost creation" do
		before { visit root_path }

		describe "with invalid data" do
			it "should not create a new micropost" do
				expect {click_button 'Post'}.not_to change(Micropost, :count)
			end
			describe "error message" do
				before { click_button 'Post' }
				it { should have_content('error') }
			end
		end

		describe "with valid info" do
			before { fill_in "micropost_content", with: "Lorem ipsum" }
			it "should create a new micropost" do
				expect {click_button 'Post'}.to change(Micropost, :count).by(1)
			end		

			describe "should redirect to the home page" do
				before do
					fill_in "micropost_content", with: "Lorem ipsum"
					click_button 'Post' 
				end 
				it { should have_selector('div.alert.alert-success',text: "published successfully" ) }
			end
			
		end 
		
	end

end
