class MicropostsController < ApplicationController
	
	before_filter :authenticate
	before_filter :authorize, 		only: [:destroy]

	def create
		@micropost=current_user.microposts.build(params[:micropost]) # params are content and in_reply_to
		if @micropost.save
			flash[:success]="Post published successfully"
			redirect_to root_path		
		else	
			@feed_items=[]	
			render 'static_pages/home'
		end
	end
	
	def destroy
		@micropost.destroy 
		redirect_to root_path
	end

	private
	def authorize
		@micropost=current_user.microposts.find_by_id(params[:id])
		redirect_to root_path if @micropost.nil?
	end
end