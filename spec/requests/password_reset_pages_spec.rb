require 'spec_helper'

describe "PasswordResetPages" do
	subject { page }
	describe "password reset form" do
		let!(:user) { FactoryGirl.create(:user) }
		describe "submitting valid user email" do
			before do
			  visit reset_password_path
			  fill_in 'Email', with: user.email
			end
			it "should send an email" do
				expect do
					click_button 'Send email'
					sleep (0.01).second					
				end.to change(Mailer.deliveries, :count).by(1)
			end
			it "should create a new password reset entry in the database" do
				expect do
					click_button 'Send email'
					sleep (0.01).second					
				end.to change(PasswordReset, :count).by(1)
			end
		end
		describe "submitting with invalid user email" do
			before do
			  visit reset_password_path
			  fill_in 'Email', with: 'fake'
			end
			it "should not send an email" do
				expect do
					click_button 'Send email'
					sleep (0.01).second					
				end.not_to change(Mailer.deliveries, :count)
			end
			it "should not create a new password reset entry in the database" do
				expect do
					click_button 'Send email'
					sleep (0.01).second					
				end.not_to change(PasswordReset, :count)
			end								
		end
	
		describe "submitting should send an email with the right parameters" do
      subject {Mailer.deliveries.last}
      before(:each) do
      	visit reset_password_path
		  	fill_in 'Email', with: user.email  
  			click_button 'Send email'
				sleep (0.01).second			     
      end      
      its(:to) { should == []<< user.email }
      its(:subject) { should =~ /password reset/ }      
    end
	end

end