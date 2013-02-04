class MicropostsController < ApplicationController
	
	before_filter :authenticate
	before_filter :authorize, 		only: [:destroy]

	def create
		@micropost=current_user.microposts.build(params[:micropost])
		if @micropost.save
			flash[:success]="Post published successfully"
			redirect_to root_path		
		else	
			@feed_items=[]
			# @feed_items=current_user.feed.paginate(page: params[:page], per_page: 5)
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