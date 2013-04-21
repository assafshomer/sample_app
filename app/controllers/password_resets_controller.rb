class PasswordResetsController < ApplicationController
  include MailersHelper

  def new
  	@title="Reset password"
  end

  def create  	
  	@title="Reset password"  	
  	@user=User.find_by_email(params[:password_reset][:email])
    if @user
      @password_reset=@user.password_resets.build  	
      if @password_reset.save!
        notify(@user,"password reset token : #{@password_reset.password_reset_token}" ) if @user
        flash[:notice] = "An email with a link to reset your password 
                          was sent to #{@user.email}..."

      else
        flash[:error] = "Failed to send a password reset link"
        render 'static_pages/home'
      end  
    else
      flash[:error] = "A user with email #{params[:password_reset][:email]} does not exist"	
    end      
  end
end
