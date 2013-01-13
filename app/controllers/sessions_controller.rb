class SessionsController < ApplicationController

	def new
		@title='Sign in' 
		session[:remember_token]=@title		
	end

	def create		
		session[:remember_token]=123
		@title ='Sign in'
		user=User.find_by_email(params[:session][:email].downcase)
		if user && user.authenticate(params[:session][:password])
			sign_in user
			redirect_to user
		else
			flash.now[:error]='Invalid email/password combination'
			render 'new'
		end
	end

	def destroy
		
	end
end
