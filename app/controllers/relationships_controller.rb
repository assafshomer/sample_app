class RelationshipsController < ApplicationController

	before_filter :authenticate, only: [:create, :destroy]

	def create
		# raise response.inspect
		@user=User.find_by_id(params[:relationship][:followed_id])
		current_user.follow!(@user)
		respond_to do |format|
			format.html { redirect_to @user }
			format.js
		end
	end
	def destroy
		# raise params.inspect		
		@user=Relationship.find_by_id(params[:id]).followed
		current_user.unfollow!(@user)
		respond_to do |format|
			format.html {	redirect_to @user}
			format.js
		end
	end
end