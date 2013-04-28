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

  def edit
    @title="Reset password"
    @password_reset=PasswordReset.find_by_password_reset_token(params[:id])
    @minutes_left=((Time.now-@password_reset.created_at)/1.minute).round
    if @password_reset && @minutes_left<1
      @user=User.find_by_id(@password_reset.user_id)        
      sign_in @user    
    else
      flash[:error] = "The reset token has expired"
      redirect_to root_path
    end
  
  end  

end
