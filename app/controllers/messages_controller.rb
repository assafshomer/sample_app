class MessagesController < ApplicationController

	before_filter :authenticate

  def new
  end

  def index
  	@title="Messages"
  	@messages=current_user.messages
  end

  def create
  end
end
