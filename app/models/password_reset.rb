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
  
  private

	  def generate_password_reset_token
	    self.password_reset_token = SecureRandom.urlsafe_base64    
	  end
  
end
