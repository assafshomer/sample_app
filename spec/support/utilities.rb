include ApplicationHelper

	def test_sign_in(user)
		# controller.sign_out if signed_in?		
		visit signin_path
		fill_in "Email",		with: user.email 
	  fill_in "Password", with: user.password 
	  click_button 'Sign in'	  
	  # post sessions_path, :email => "foo@bar.com", 
	  # 										:password => "foobar", 
	  # 										:password_confirmation => "foobar"
	end
	

