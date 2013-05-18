class UsersController < ApplicationController
  before_filter :authenticate,       except: [:new, :create, :destroy]
  before_filter :verify_correct_user,  only: [:edit, :update]
  before_filter :non_admins,           only: :destroy
  before_filter :no_visits,            only: [:new, :create]

	def index    
		@title="All users"      
		# @users=User.all.sort_by {|user| user.name}    
    # @users=User.paginate(page: params[:page], per_page: 10).order('name') 
    @users=search_users(params[:search]).paginate(page: params[:page], 
                          per_page: 10).order('name')
    redirect_to users_path if params[:commit]=='Clear'
	end

	def show		 
  	@user=User.find(params[:id])  	
  	@microposts=search_microposts_content(params[:search],@user).paginate(page: params[:page], per_page: 10)
    @message=current_user.messages.build(recipient_id: @user.id) if @user.following?(current_user)
    @title=@user.name
    @followed_user_relationship=current_user.relationships.find_by_followed_id(@user.id)
    @followed_user_relationship ||= current_user.relationships.build(followed_id: @user.id)
    redirect_to user_path(@user) if params[:commit]=='Clear'
  end

  def following
    @title='Following'
    @user=User.find(params[:id])
    # @users=@user.followed_users.paginate(page: params[:page], per_page: 10)
    @users=search_following(params[:search], @user).paginate(page: params[:page], per_page: 10)
    @users_100=@user.followed_users.first(100) #for the status area
    if params[:commit]=='Clear'
      redirect_to following_user_path(@user) 
    else
      render 'show_follow' 
    end
  end

  def followers
    @title='Followers'
    @user=User.find(params[:id])
    # @users=@user.followers.paginate(page: params[:page], per_page: 10)
    @users=search_followers(params[:search], @user).paginate(page: params[:page], per_page: 10)
    @users_100=@user.followers.first(100)
    if params[:commit]=='Clear'
      redirect_to followers_user_path(@user) 
    else
      render 'show_follow' 
    end
  end

  def new
  	@title='Sign Up'
    @user=User.new
  end

  def create
    @user=User.new(params[:user])    
    if @user.save
      @email_verification=@user.create_email_verification
      Mailer.send_email_verification_email(@email_verification)
      flash[:success] = "Verification email was sent to #{@user.email}"
      redirect_to root_path
    else      
      render 'new'
    end
  end 

  def edit    
    @title='Edit user'
    # @user=User.find_by_id(params[:id])
  end

  def update    
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

  def no_visits
    redirect_to root_path unless !signed_in?
  end

  def search_users(space_separated_search_terms)    
    if !space_separated_search_terms.blank?      
      User.where(generate_sql(space_separated_search_terms, 'name email', User))
    else
      User
    end
  end
  def search_followers(space_separated_search_terms, user)    
    if !space_separated_search_terms.blank?      
      user.followers.where(generate_sql(space_separated_search_terms, 'name email', User))
    else
      user.followers
    end
  end
  def search_following(space_separated_search_terms, user)    
    if !space_separated_search_terms.blank?      
      user.followed_users.where(generate_sql(space_separated_search_terms, 'name email', User))
    else
      user.followed_users
    end
  end
  def search_microposts_content(space_separated_search_terms, user)    
    if !space_separated_search_terms.blank?      
      user.microposts.where(generate_sql(space_separated_search_terms, 'content', Micropost))
    else
      user.microposts
    end
  end  

end
