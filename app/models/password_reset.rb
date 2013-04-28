# == Schema Information
#
# Table name: password_resets
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  password_reset_token :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  active               :boolean          default(TRUE)
#

class PasswordReset < ActiveRecord::Base

  belongs_to :user
  before_save :generate_password_reset_token

  validates :user_id, presence: true  
  validate :real_user?
  
  @@token_expiration_minutes=120

  def expired?
  	time_passed > @@token_expiration_minutes
  end

  def active_and_not_expired?
  	active && !expired?
  end

  def time_passed
  	((Time.now-self.created_at)/1.minute).round
  end

  def minutes_left
  	@@token_expiration_minutes-time_passed
  end

  def self.expiration_time_in_minutes
  	@@token_expiration_minutes
  end

  private

	  def generate_password_reset_token
	    self.password_reset_token = SecureRandom.urlsafe_base64 if active?
	  end

	  def real_user?
	  	err_msg="no user with this ID exists"
	  	errors.add(:user_id, err_msg) unless User.find_by_id(user_id)
	  end

end
