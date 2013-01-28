class UsersController < ApplicationController
  before_filter :signed_in_user,       only: [:edit, :update, :index]
  before_filter :verify_correct_user,  only: [:edit, :update]
  before_filter :non_admins,           only: :destroy

	def index
		@title="All users"
		# @users=User.all.sort_by {|user| user.name}    
    @users=User.paginate(page: params[:page], :per_page => 10).order('name')    
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

  def destroy
    deadman=User.find_by_id(params[:id]) 
    name=deadman.name
    deadman.destroy
    flash[:success] = "Successfully deleted #{name}"
    redirect_to users_path
  end
  
  private

  def signed_in_user
    deny_access unless signed_in?    
  end

  def verify_correct_user
    @user=User.find_by_id(params[:id])     
    redirect_to root_path unless current_user?(@user)
  end

  def non_admins
    redirect_to root_path unless current_user.admin? 
    # note this will not work if instead we try to use @current_user.admin? even though 
    # the instance variable @current_user is available in this context. The reason is that 
    # it is only set to something not nil due to test_sign_in AFTER we hit the create action
    # but the before filter occurs before it, so @current_user is nil at that time. However, 
    # the method current_user assigns to @current_user the user that just posted to
    # test_sign_in in @current_user is null.
  end
end
