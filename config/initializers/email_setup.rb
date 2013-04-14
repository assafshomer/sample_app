require 'dev_mail_interceptor'

ActionMailer::Base.smtp_settings = {
	address: "smtp.gmail.com",
	port: 587, 
	domain: "fake.com",
	user_name: "assafshomersecond",
	password: "foobarbaz",
	authentication: "plain",
	enable_starttls_auto: true
}

ActionMailer::Base.default_url_options[:host] = "localhost:3000"
ActionMailer::Base.register_interceptor(DevMailInterceptor) if Rails.env.development?