class Mailer < ActionMailer::Base
  default from: "me@sample.app"

  def prepare_email(address, subject)  	
  	mail(to: address, subject: subject)  	
  end

end
