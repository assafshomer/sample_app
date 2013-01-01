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

require 'spec_helper'

describe "User" do
	before(:each) do 
		@attr={name: "Example User", email: "user@example.com"}		
		@user=User.new(@attr)
	end
	
	subject { @user }
	it { should respond_to(:name) }
	it { should respond_to(:email) }
	it { should be_valid } #sanity check, our @user is valid
	describe "shold reject users without a name" do
	 	before { @user.name=""}
		it {should_not be_valid}
	 end 
	describe "shold reject users without an email" do
	 	before { @user.email=""}
		it {should_not be_valid}
	 end 
	describe "disallow names longer than 50 characters" do
		before {@user.name="a"*51}
		it {should_not be_valid}
	end
	describe "when email is well formatted, valid" do
		it "should be valid" do
			good_addresses=%w[assaf@example.com 123@456.org 123@456.890 _assaf@email.com]
			good_addresses.each do |valid_address|
				@user.email=valid_address
				@user.should be_valid
			end
		end		
	end
	describe "when email is well formatted, valid" do
		it "should be invalid" do
			bad_addresses=%w[assaf_at_wrong.place !@foo.bar abc@example.org. .assaf@.gmail -hypen@-hypen dot@..dot...org dot@..dot.org]
			bad_addresses.each do |invalid_address|
				@user.email=invalid_address
				@user.should_not be_valid
			end
		end		
	end

	describe "when email address is already taken" do
		before do
			user_with_same_email=@user.dup
			user_with_same_email.email=@user.email.upcase
			user_with_same_email.save
		end
			it {should_not be_valid}					
	end





end 
