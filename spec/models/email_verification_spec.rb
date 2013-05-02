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

require 'spec_helper'

describe EmailVerification do
	let!(:user) { FactoryGirl.create(:user) }
	let!(:email_verification) { user.build_email_verification }
  
  subject { email_verification }  

  it { should respond_to('token') }
  it { should respond_to('user_id') }
  it { should respond_to('active') }  
  its(:user_id) { should == user.id }

  describe "validations" do
  	let!(:ev) { FactoryGirl.create(:email_verification) }
  	let!(:max_user_id) { User.all.map(&:id).max }
  	subject {ev}
  	describe "valid" do	  
	  	it { should be_valid }
  	end
  	describe "invalid" do	  	
  		before { ev.user_id=max_user_id+100 }
	  	it { should_not be_valid }
  	end  	
  end
  describe "activation" do
  	it "something to test activation"
  end 

 
end
