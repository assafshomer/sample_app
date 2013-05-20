# == Schema Information
#
# Table name: microposts
#
#  id          :integer          not null, primary key
#  content     :string(255)
#  user_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  in_reply_to :integer
#

class Micropost < ActiveRecord::Base
	include MicropostsHelper
  attr_accessible :content, :in_reply_to
  belongs_to :user  

  validates :content, presence: true, length: {maximum: 140, minimum: 2}
  validates :user_id, presence: true

  default_scope -> { order('created_at DESC') }
  scope :from_users_followed_by, lambda {|user| followed_by(user)}
  scope :smart_feed, lambda{|user| followed_by_not_reply(user)}

  private
  	def self.followed_by(user)
  		followed_user_ids=%(SELECT followed_id FROM relationships 
  												WHERE follower_id=:user_id)  	
  		where("user_id IN (#{followed_user_ids}) OR user_id= :user_id", user_id: user)  		
  	end  

    def self.followed_by_not_reply(user)
      followed_user_ids=%(SELECT followed_id FROM relationships 
                          WHERE follower_id=:user_id)
      query=%((user_id IN (#{followed_user_ids}) AND in_reply_to IS NULL) 
                OR user_id= :user_id
                OR in_reply_to= :user_id)                             
      where(query, user_id: user)     
    end       

  # def self.from_users_followed_by(user)
  # 	# followed_user_ids=user.followed_users.map(&:id).join(", ")
  # 	# followed_user_ids=user.followed_user_ids.join(", ") # this is a rails shortcut for the above
		# followed_user_ids="SELECT followed_id FROM relationships WHERE follower_id=:user_id "  	
  # 	where("user_id IN (#{followed_user_ids}) OR user_id= :user_id", user_id: user)
  # end
end
