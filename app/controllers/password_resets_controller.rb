class PasswordResetsController < ApplicationController
  
  def new
  	@title="Reset password"
  end

  def create  	
  	@title="Reset password"
  	@user=User.find_by_email(params[:password_reset][:email])
    if @user
      @password_reset=@user.password_resets.build  	
      if @user.active
        if @password_reset.save!
        Mailer.send_password_reset_email(@password_reset) if @user        
        redirect_to root_path, notice: "A password reset link was sent to #{@user.email}"
        end  
      else
        flash[:error] = "Before resetting your password,
                           activate your account by clicking the link sent to #{@user.email}"
        redirect_to root_path                           
      end
    else
      flash[:error] = "No user with email address 
                      \'#{params[:password_reset][:email]}\' was found"	
      redirect_to reset_password_path                      
    end      
  end

  def edit
    @title="Reset password"
    @password_reset = PasswordReset.find_by_password_reset_token(params[:id])         
    if @password_reset && @password_reset.active_and_not_expired?
      @minutes_left=@password_reset.minutes_left 
      @password_reset.toggle!(:active)
      @user=@password_reset.user
      sign_in @user    
    else
      flash[:error] = "Invalid reset token"
      redirect_to root_path
    end
  
  end  

end
