# == Schema Information
#
# Table name: password_resets
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  password_reset_token :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class PasswordReset < ActiveRecord::Base

  belongs_to :user
  before_save :generate_password_reset_token

  validates :user_id, presence: true  
  validate :real_user?

  private

	  def generate_password_reset_token
	    self.password_reset_token = SecureRandom.urlsafe_base64    
	  end

	  def real_user?
	  	err_msg="no user with this ID exists"
	  	errors.add(:user_id, err_msg) unless User.find_by_id(user_id)
	  end
  
end
