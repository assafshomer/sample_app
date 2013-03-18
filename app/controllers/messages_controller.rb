class MessagesController < ApplicationController

	before_filter :authenticate

  def new
  end

  def index
  	@title="Messages"
  	@messages=current_user.messages.paginate(page: params[:page], per_page: 10)
  end

  def create
  end
end
