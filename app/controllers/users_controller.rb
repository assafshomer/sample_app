class UsersController < ApplicationController
  
	def index
		@title="Users"
		@users=User.all
	end


	def show		
  	@user=User.find(params[:id])  	
  	@title=@user.name 
  end

  def new
  	@title='Sign Up'
    @user=User.new
  end

  def create
    @user=User.new(params[:user])    
    if @user.save
      flash[:success] = "Welcome to the sample app"
      redirect_to user_path(@user.id)
    else      
      render 'new'
    end
  end
  
end
