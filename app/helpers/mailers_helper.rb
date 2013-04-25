module MailersHelper

	def send_new_follower_email_to(user)
		subject="Hello #{@user.name}, #{current_user.name} is now following you"
		notify(user.email,subject)
	end

	def send_user_stopped_following_email_to(user)
		subject="Hello #{@user.name}, #{current_user.name} is no longer following you"
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

