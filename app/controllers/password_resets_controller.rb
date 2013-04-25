class PasswordResetsController < ApplicationController
  

  def new
  	@title="Reset password"
  end

  def create  	
  	@title="Reset password"  	
  	@user=User.find_by_email(params[:password_reset][:email])
    if @user
      @password_reset=@user.password_resets.build  	
      if @password_reset.save!
        Mailer.send_password_reset_email(@password_reset) if @user        
        redirect_to root_path, notice: "A password reset link was sent to #{@user.email}"
      end  
    else
      flash[:error] = "No user with email address 
                      \'#{params[:password_reset][:email]}\' was found"	
      redirect_to reset_password_path                      
    end      
  end
end
