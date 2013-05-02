class EmailVerificationsController < ApplicationController
  def edit
  	@title="Email verification"
  	@email_verification=EmailVerification.find_by_token(params[:id])
  	@user=@email_verification.user      	
  	@user.toggle!(:active) unless @user.active?
	  sign_in @user
	  flash[:success] = "Welcome to my Twitter clone"
	  redirect_to @user  	
  end
end
