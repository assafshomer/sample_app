class Mailer < ActionMailer::Base
  default from: "me@sample.app"

  def prepare_email(address, subject) 
  	@address=address
  	@subject=subject 	
  	mail(to: @address, subject: @subject)  	
  end
	
	def send_new_follower_email_to(followed,follower)
		subject="Hello #{followed.name}, #{follower.name} is now following you"
		send_email(followed.email,subject)
	end

	def send_user_stopped_following_email_to(followed,follower)
		subject="Hello #{followed.name}, #{follower.name} is no longer following you"
		send_email(followed.email,subject)
	end

	def send_password_reset_email(password_reset)
		@user=password_reset.user
		@password_reset_token=password_reset.password_reset_token
		subject="password reset token : #{@password_reset_token}"		
		send_email(@user.email,subject)
	end

	def send_email_verification_email(email_verification)
		@email_verification=email_verification
		@user=@email_verification.user
		subject="email verification for #{@user.name}"		
		send_email(@user.email,subject)
	end	

	private
		def send_email(address, subject) 		 
			@address=address
  		@subject=subject 	  		
			email=mail(to: @address, subject: @subject)  	          
	  	if Rails.env.test?
	  		email.deliver 
	  	else
	  		thread=Thread.new {email.deliver} 
	  	end
		end
end
