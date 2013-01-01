# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ActiveRecord::Base
  attr_accessible :email, :name

	before_save { |user| user.email = email.downcase }

  VALID_EMAIL_REGEX=/^(\d|\w)(\d|\w|[.\-])*@((\d|\w)+\.)*(\d|\w)+$/
  validates :name, presence: true, length: {maximum: 50}
  validates :email, presence: true, format: {with: VALID_EMAIL_REGEX}, 
  									uniqueness: {case_sensitive: false}
end
