# == Schema Information
#
# Table name: relationships
#
#  id          :integer          not null, primary key
#  follower_id :integer
#  followed_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'spec_helper'
	
describe Relationship do
	let(:follower) { FactoryGirl.create(:user) }
	let(:followed) { FactoryGirl.create(:user) }
	let(:relationship) { follower.relationships.build(followed_id: followed.id) }

	subject { relationship }

	it { should be_valid }

	describe "accessible attributes" do
		it "should not allow access to follower_id" do
			expect do
  		  Relationship.new(follower_id: follower.id)
  		end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)  				
		end		
	end

	describe "follower methods" do
		it { should respond_to(:follower) }
		it { should respond_to(:followed) }
		its(:follower) { should == follower }
		its(:followed) { should == followed }
	end

	describe "validations" do
		describe "reject if no follower_id" do
			before { relationship.follower=nil }
			it { should_not be_valid }
		end
		describe "reject if no followed_id" do
			before { relationship.followed=nil }
			it { should_not be_valid }
		end
		describe "reject if following itself" do
			before { relationship.followed_id=relationship.follower_id}
			it { should_not be_valid }
		end
	end

end

	


