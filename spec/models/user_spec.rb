# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string(255)
#  remember_token  :string(255)
#  admin           :boolean          default(FALSE)
#

require 'spec_helper'
include TestUtilities

describe "User" do
	before(:each) do 
		@attr={name: "Example User", email: "user@example.com",
			password: "foobar", password_confirmation: "foobar"}		
		@user=User.new(@attr)
	end
	
	subject { @user } 

	it { should respond_to(:name) }
	it { should respond_to(:email) }
	it { should respond_to(:password_digest) }
	it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate)}
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }
  it { should respond_to(:microposts) }

	it { should be_valid } #sanity check, our @user is valid
	it { should_not be_admin }

	describe "should be rejected without a name" do
	 	before { @user.name=""}
		it {should_not be_valid}
	 end 
	describe "should be rejected without an email" do
	 	before { @user.email=""}
		it {should_not be_valid}
	 end 
	describe "should not have longer than 50 characters" do
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

	describe "when email address is different only by case" do
		before do
			user_with_same_email=@user.dup
			user_with_same_email.email=reverse_string_case(@user.email)
			user_with_same_email.save
		end
			it {should_not be_valid}					
	end

	describe "user authentication" do
		
		describe "reject users with no password" do
			before {@user.password=@user.password_confirmation=""}
			it {should_not be_valid}			
		end

		describe "when password doesn't match password_confirmation" do
			before {@user.password_confirmation="mismatch"}
			it {should_not be_valid}
		end

		describe "password_confirmation should not be nil" do
			before {@user.password_confirmation=nil}
			it {should_not be_valid}
		end

		describe "return value of authenticate method" do
		  before { @user.save }
		  let(:found_user) { User.find_by_email(@user.email) }

		  describe "with valid password" do
		    it { should == found_user.authenticate(@user.password) }
		  end

		  describe "with invalid password" do
		    let(:user_for_invalid_password) { found_user.authenticate("invalid") }

		    it { should_not == user_for_invalid_password }
		    specify { user_for_invalid_password.should be_false }
		  end
		end

		describe "with a password that's too short" do
		  before { @user.password = @user.password_confirmation = "a" * 5 }
  		it { should be_invalid }
		end
	end

	describe "should have a non-blank remember_token" do
		before { @user.save }
		its(:remember_token) { should_not be_blank }		
	end

	describe "admins" do
		describe "can be created by toggling a non-admin" do
			before do
		  	@user.save!
		  	@user.toggle!(:admin)
			end
			it { should be_admin }			
		end

		describe "accessible attriubtes" do
			it "should not allow access to the 'admin' attribute" do
				expect do
					User.new(name: "my name", email: "admin@admin.org", admin: true)
				end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
			end			
		end
	end
end 
