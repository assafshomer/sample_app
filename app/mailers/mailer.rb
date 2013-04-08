class Mailer < ActionMailer::Base
  default from: "me@sample.app"

  def prepare_email(address, subject)  	
  	mail(to: address, subject: subject)  	
  end

  def random_email
  	mail(to: fake_address, subject: fake_subject)  	
  end

end
