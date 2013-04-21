class PasswordResetsController < ApplicationController
  def new
  	@title="Reset password"
  end

  def create
  	@title="Reset password"
  	user=User.find_by_email(params[:email])
  	Mailer.prepare_email('assafshomer@gmail.com','testing pass').deliver
  end
end
