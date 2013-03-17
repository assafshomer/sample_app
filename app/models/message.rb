# == Schema Information
#
# Table name: messages
#
#  id           :integer          not null, primary key
#  content      :string(255)
#  sender_id    :integer
#  recipient_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Message < ActiveRecord::Base
  attr_accessible :content, :recipient_id

  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"

  validates :sender_id, presence: true
  validates :recipient_id, presence: true
  validates :content, presence: true, length: {maximum: 140, minimum: 2}
  validate :recipient_is_follower?

  def recipient_is_follower?
  	if  !recipient.nil? and !sender.nil?
  		error_msg="'#{sender.name}' cannot send '#{recipient.name}' a message because '#{recipient.name}' is not following '#{sender.name}'"
  		errors.add(:recipient_id,error_msg ) unless recipient.following?(sender)
  	end  	
  end  
  
end
