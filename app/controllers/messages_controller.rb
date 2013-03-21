class MessagesController < ApplicationController

	before_filter :authenticate

  def index
  	@title="Messages"
  	@messages=current_user.mailbox.paginate(page: params[:page],
  																			 per_page: 10)
  end

	def create
		@message=current_user.messages.build(params[:message]) 		
		if @message.save
			flash[:success]="Direct message sent successfuly to #{@message.recipient.name}"
			redirect_to messages_path	
		else				
			@user=@message.recipient
			@microposts=@user.microposts.paginate(page: params[:page], per_page: 10)
			render 'users/show'
		end
	end
end
