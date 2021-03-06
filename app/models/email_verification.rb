# == Schema Information
#
# Table name: email_verifications
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  token      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class EmailVerification < ActiveRecord::Base
  belongs_to :user
  before_save :generate_token

	validates :user_id, presence: true  
  validate :real_user?

  private

	  def generate_token
	    self.token = SecureRandom.urlsafe_base64
	  end

	  def real_user?
	  	err_msg="no user with this ID exists"
	  	errors.add(:user_id, err_msg) unless user
	  end

end
