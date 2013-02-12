class RelationshipsController < ApplicationController

	before_filter :authenticate, only: [:create, :destroy]

	def create
		# raise response.inspect
		followed_user=User.find_by_id(params[:relationship][:followed_id])
		current_user.follow!(followed_user)
		redirect_to followed_user
	end
	def destroy
		# raise params.inspect		
		followed_user=Relationship.find_by_id(params[:id]).followed
		current_user.unfollow!(followed_user)
		redirect_to followed_user
	end
end