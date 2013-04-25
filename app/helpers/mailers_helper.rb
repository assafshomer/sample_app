module MailersHelper

	def send_new_follower_email_to(user)
		subject="Hello #{user.name}, #{current_user.name} is now following you"
		notify(user.email,subject)
	end

	def send_user_stopped_following_email_to(user)
		subject="Hello #{user.name}, #{current_user.name} is no longer following you"
		notify(user.email,subject)
	end

	def send_password_reset_email(password_reset)
		subject="password reset token : #{password_reset.password_reset_token}"
		user=User.find_by_id(password_reset.user_id)
		notify(user.email,subject)
	end
	
	private
		def notify(address, subject) 		           
	  	if Rails.env.test?
	  		Mailer.prepare_email(address,subject).deliver 
	  	else
	  		thread=Thread.new {Mailer.prepare_email(address,subject).deliver} 
	  	end
		end

end

