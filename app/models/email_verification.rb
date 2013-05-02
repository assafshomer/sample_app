# == Schema Information
#
# Table name: email_verifications
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  token      :string(255)
#  active     :boolean          default(TRUE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class EmailVerification < ActiveRecord::Base
  belongs_to :user
end
