class StaticPagesController < ApplicationController
  def home
  	# @title="Home"
    if signed_in?
      @micropost=current_user.microposts.build
      @feed_items=current_user.feed.paginate(page: params[:page], per_page: 5)
      @filtered_feed=search_feed(params[:search]).paginate(page: params[:page], per_page: 5)
      redirect_to root_path if params[:commit]=='Clear'
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


  private

    def search_feed_by_content(space_separated_search_terms)    
      if !space_separated_search_terms.blank?      
        # The search below creates the correct array, but braks paginate
        # current_user.feed.where(generate_LIKE_sql(space_separated_search_terms, 'content')) +
        # current_user.feed.where("user_id IN (#{User.where(generate_LIKE_sql(space_separated_search_terms,'name', 'email')).map(&:id).join(',')})")
        current_user.feed.where(generate_LIKE_sql(space_separated_search_terms, 'content',Micropost))
      else
        current_user.feed
      end
    end

  def search_feed(space_separated_search_terms)    
    if !space_separated_search_terms.blank?      
      current_user.feed.where(generate_search_microposts_sql(space_separated_search_terms))
    else
      current_user.feed
    end
  end  

end
