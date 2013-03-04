# == Schema Information
#
# Table name: microposts
#
#  id         :integer          not null, primary key
#  content    :string(255)
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Micropost < ActiveRecord::Base
	include MicropostsHelper
  attr_accessible :content
  belongs_to :user  

  validates :content, presence: true, length: {maximum: 140, minimum: 2}
  validates :user_id, presence: true

  default_scope order: 'microposts.created_at DESC'
  scope :from_users_followed_by, lambda {|user| followed_by(user)}

  private
  	def self.followed_by(user)
  		followed_user_ids=%(SELECT followed_id FROM relationships 
  												WHERE follower_id=:user_id)  	
  		where("user_id IN (#{followed_user_ids}) OR user_id= :user_id", user_id: user)  		
  	end

  # def self.from_users_followed_by(user)
  # 	# followed_user_ids=user.followed_users.map(&:id).join(", ")
  # 	# followed_user_ids=user.followed_user_ids.join(", ") # this is a rails shortcut for the above
		# followed_user_ids="SELECT followed_id FROM relationships WHERE follower_id=:user_id "  	
  # 	where("user_id IN (#{followed_user_ids}) OR user_id= :user_id", user_id: user)
  # end
end
