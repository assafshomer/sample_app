class StaticPagesController < ApplicationController
  def home
  	# @title="Home"
    if signed_in?
      @micropost=current_user.microposts.build
      @feed_items=current_user.feed.paginate(page: params[:page], per_page: 5)
    end
  end

  def help 
  	@title="Help"
  end

  def about
  	@title="About Us"
  end

  def contact
  	@title="Contact"
  end


end
