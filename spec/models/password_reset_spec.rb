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
  it { should respond_to('active') }
  its(:user_id) { should == user.id }

  describe "validations" do
  	let!(:reset) { FactoryGirl.create(:password_reset) }
  	let!(:max_user_id) { User.all.map(&:id).max }
  	subject {reset}
  	describe "valid" do	  
	  	it { should be_valid }
  	end
  	describe "invalid" do	  	
  		before { reset.user_id=max_user_id+100 }
	  	it { should_not be_valid }
  	end  	
  end
  describe "activation" do
    let!(:expiration_time_in_minutes) { PasswordReset.expiration_time_in_minutes }
    let!(:pr) { FactoryGirl.create(:password_reset, created_at: (expiration_time_in_minutes+1).minutes.ago) }
    it { should be_active }
    specify {pr.should_not be_active}
  end
end
