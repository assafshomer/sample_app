module MailersHelper
	
	def notify(user, message) 		           
  	if Rails.env.test?
  		Mailer.prepare_email(user.email,message).deliver if user
  	else
  		thread=Thread.new {Mailer.prepare_email(user.email,message).deliver} if user      		
  	end
	end
	
end

