require 'spec_helper'

describe "PasswordResetPages" do
	subject { page }
	describe "password reset form" do
		before { visit reset_password_path }		
		it "submitting should send an email" do
			expect do
				click_button 'Retrieve password'
			end.to change(Mailer.deliveries, :count).by(1)
		end
	end
end
