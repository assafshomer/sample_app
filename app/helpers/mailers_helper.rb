module MailersHelper
	
	def notify(address, subject) 		           
  	if Rails.env.test?
  		Mailer.prepare_email(address,subject).deliver 
  	else
  		thread=Thread.new {Mailer.prepare_email(address,subject).deliver} 
  	end
	end
	
end

