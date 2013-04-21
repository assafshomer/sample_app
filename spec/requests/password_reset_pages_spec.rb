require 'spec_helper'

describe "PasswordResetPages" do
	subject { page }
	describe "password reset form" do
		let!(:user) { FactoryGirl.create(:user) }
		before do
		  visit reset_password_path
		  fill_in 'Email', with: user.email
		end
		it "submitting should send an email" do
			expect do
				click_button 'Send email'
				sleep (0.01).second					
			end.to change(Mailer.deliveries, :count).by(1)
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
      its(:subject) { should=="password reset test" }      
    end
	end

end
