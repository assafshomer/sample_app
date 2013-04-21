class SessionsController < ApplicationController

	def new
		@title='Sign in' 
	end

	def create			
		@title ='Sign in'
		user=User.find_by_email(params[:session][:email].downcase)
		if user && user.authenticate(params[:session][:password])
			sign_in user, params[:session][:remember_me]
			flash[:success]="Welcome back #{user.name}"
			redirect_back_or user 
		else
			flash.now[:error]='Invalid email/password combination'
			clear_stored_location
			render 'new'
		end
	end

	def destroy
		sign_out
		redirect_to root_path
	end
end