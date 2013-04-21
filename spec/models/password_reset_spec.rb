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

require 'spec_helper'

describe PasswordReset do
  let!(:user) { FactoryGirl.create(:user) }
  before do
  	@reset=user.password_resets.build  
  end

  subject { @reset }  

  it { should respond_to('password_reset_token') }
  it { should respond_to('user_id') }
  its(:user_id) { should == user.id }

end
