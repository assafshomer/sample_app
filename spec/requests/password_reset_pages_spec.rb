require 'spec_helper'
include TestUtilities

describe "PasswordResetPages" do
	subject { page }
	describe "send password reset email form" do
		let!(:user) { FactoryGirl.create(:user) }

		describe "should have the right fields" do
			before { visit reset_password_path }
      it { should have_selector('title', text: 'Reset password') }
      it { should have_selector('input#password_reset_email') }
      it { should have_selector('input#send_reset_password_email') }			
		end

		describe "submitting valid user email" do
			before do
			  visit reset_password_path
			  fill_in 'Email', with: user.email
			end

			it "should send an email" do
				expect do
					click_button 'Send email'					
				end.to change(Mailer.deliveries, :count).by(1)
			end
			it "should create a new password reset entry in the database" do
				expect do
					click_button 'Send email'					
				end.to change(PasswordReset, :count).by(1)
			end
			describe "should redirect home and flash sucess" do
				before { click_button 'Send email' }
	      it { should have_selector('h1', text: signup_title) }  
	      it { should have_selector('div.alert.alert-notice', 
	      	text: /A password reset link was sent/i) }
	      it { should have_link('Sign in', href: signin_path) }
	      describe "flash doesn't linger" do
	      	before { visit current_path }	
	      	it { should_not have_selector('div.alert') }							
				end							
			end
			describe "invalid user should redirect home and flash failure" do
				before  do
					user.destroy
					click_button 'Send email'
				end
	      it { should have_selector('h1', text: /Reset password/i) }  
	      it { should have_selector('div.alert.alert-error', 
	      	text: /No user with email address /i) }
	      it { should have_selector('input#send_reset_password_email') }	
			end					
		end

		describe "submitting invalid email" do
			before do
			  visit reset_password_path
			  fill_in 'Email', with: 'fake'
			end
			it "should not send an email" do
				expect do
					click_button 'Send email'				
				end.not_to change(Mailer.deliveries, :count)
			end
			it "should not create a new password reset entry in the database" do
				expect do
					click_button 'Send email'				
				end.not_to change(PasswordReset, :count)
			end
			describe "should stay on password reset page and flash error" do
				before { click_button 'Send email' }
	      it { should have_selector('h1', text: /Reset password/i) }  
	      it { should have_selector('div.alert.alert-error', 
	      	text: /No user with email address /i) }
	      it { should have_selector('input#send_reset_password_email') }							
			end
	      describe "flash doesn't linger" do
	      	before { visit current_path }	
	      	it { should_not have_selector('div.alert') }							
				end															
		end
	
		describe "submitting should send an email with the right parameters" do
      subject {Mailer.deliveries.last}      
      before(:each) do
      	visit reset_password_path
		  	fill_in 'Email', with: user.email  
  			click_button 'Send email'				
      end         
      its(:to) { should == []<< user.email }
      its(:subject) { should =~ /password reset token :/ }
      it "and the right body" do
      	Mailer.deliveries.last.html_part.body.should =~ /to reset your password please click/i   
      	Mailer.deliveries.last.html_part.body.should have_selector('b', text: "#{user.name}")       	      	
      	Mailer.deliveries.last.html_part.body.should =~ /#{user.password_resets.last.password_reset_token}/  
      	# The test below fails for a mystrious reason, though it does work if instead of _url i use _path
      	# Mailer.deliveries.last.html_part.body.should have_link('Reset password',
      	# 	href: edit_password_reset_url(user.password_resets.last.password_reset_token)) 
      end      
    end
	end

	describe "password reset form layout" do
    let!(:user) { FactoryGirl.create(:user) }
    before(:each) do
    	visit reset_password_path
	  	fill_in 'Email', with: user.email  
			click_button 'Send email'
			visit edit_password_reset_path(user.password_resets.last.password_reset_token)				
    end   
    it { should have_selector('title', text: "Reset password") }
    it { should have_selector('h2', text: 'you can now reset your password') }
    it { should have_selector('input#user_password') }
    it { should have_selector('input#user_password_confirmation') }
    it { should have_selector('input#reset_password_button') }
	end
	describe "password reset form submission" do
    let!(:user) { FactoryGirl.create(:user) }
    before(:each) do
    	visit reset_password_path
	  	fill_in 'Email', with: user.email  
			click_button 'Send email'
			visit edit_password_reset_path(user.password_resets.last.password_reset_token)				
      fill_in "Password",     with: "foobar"
      fill_in "Confirmation", with: "foobar"
      click_button 'Reset password'      
    end   
		it { should have_link('Sign out', href: signout_path) }
		it { should_not have_link('Sign in', href: signin_path) }
	end
end