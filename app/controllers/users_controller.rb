class UsersController < ApplicationController
  before_filter :signed_in_user,       only: [:edit, :update]
  before_filter :verify_correct_user,  only: [:edit, :update]

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
      sign_in @user
      flash[:success] = "Welcome to the sample app"
      redirect_to @user
    else      
      render 'new'
    end
  end 

  def edit
    @title='Edit user'
    # @user=User.find_by_id(params[:id])
  end

  def update
    # @user=User.find_by_id(params[:id])
    
    if @user.update_attributes(params[:user])
      sign_in @user
      flash[:success] = "User data was sucessfully updated"
      redirect_to @user      
    else      
      render 'edit'
    end
  end
  
  private

  def signed_in_user
    redirect_to signin_path, notice: "Please sign in." unless signed_in?    
  end

  def verify_correct_user
    @user=User.find_by_id(params[:id])     
    redirect_to root_path unless current_user?(@user)
  end
end