module MailersHelper
	
	def notify(user, message) 		           
  	thread=Thread.new {Mailer.prepare_email(user.email,message).deliver} if user      
	end

end

