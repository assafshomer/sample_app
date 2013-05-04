class EmailVerificationsController < ApplicationController
  def edit
  	@title="Email verification"
  	@email_verification=EmailVerification.find_by_token(params[:id])
  	@user=@email_verification.user      	
  	@user.toggle!(:active) unless @user.active?
	  sign_in @user
	  flash[:success] = "#{@user.name}, your email was verified. Welcome to my twitter clone"
	  redirect_to @user  	
  end
end
