class PasswordResetsController < ApplicationController
  include MailersHelper

  def new
  	@title="Reset password"
  end

  def create  	
  	@title="Reset password"  	
  	user=User.find_by_email(params[:password_reset][:email])
  	# Mailer.prepare_email(user.email,"testing pass #{Time.now}").deliver if user
  	notify(user,'password reset test' ) if user
  end
end
