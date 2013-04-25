class RelationshipsController < ApplicationController
	include MailersHelper
	before_filter :authenticate, only: [:create, :destroy]

	def create
		# raise response.inspect
		@user=User.find_by_id(params[:relationship][:followed_id])
		current_user.follow!(@user)
		send_new_follower_email_to(@user) if @user.recieve_notifications?
		respond_to do |format|
			format.html { redirect_to @user }
			format.js
		end
	end
	def destroy
		# raise params.inspect		
		@user=Relationship.find_by_id(params[:id]).followed
		current_user.unfollow!(@user)		
		send_user_stopped_following_email_to(@user) if @user.recieve_notifications?
		respond_to do |format|
			format.html {	redirect_to @user}
			format.js
		end
	end
	
end