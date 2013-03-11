# == Schema Information
#
# Table name: microposts
#
#  id          :integer          not null, primary key
#  content     :string(255)
#  user_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  in_reply_to :integer
#

require 'spec_helper'

describe Micropost do
  
  let(:user) { FactoryGirl.create(:user) }
  before do
    @micropost=user.microposts.build(content: "Lorem ipsum")
  end

  subject {@micropost}

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }  
  it { Micropost.should respond_to(:from_users_followed_by) }
  it { should respond_to(:in_reply_to) } 
  
  its(:user) { should==user }

  it { should be_valid }
  describe "without user_id" do
  	before { @micropost.user_id=nil }
  	it { should_not be_valid }
  end

  describe "accessible attributes" do
  	it "-user_id should not be mass assigned" do
  		expect do
  		  Micropost.new(content: "lorem", user_id: 1)
  		end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)  		
  	end  	
  end

  describe "content" do
  	describe "should not be blank" do
  		before { @micropost.content="   "}
  		it { should_not be_valid }  		
  	end

    describe "should be longer than a single character" do
      before { @micropost.content="." }
      it { should_not be_valid }
    end
  	
  	describe "should be less than 140 chars" do
  		before { @micropost.content= "a" * 141 }
  		it { should_not be_valid }
  	end

  	describe "shoule be able to be 140 chars long" do
  		before { user.microposts.create(content: "b"*140) }
  		it { should be_valid }  		
  	end
  end

end 
