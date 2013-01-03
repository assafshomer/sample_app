class UsersController < ApplicationController
  
	def show
		@title='Sign Up' 
  	@user=User.find(params[:id])  	
  end

  def new
  	@title='Sign Up'
  end
  
end
