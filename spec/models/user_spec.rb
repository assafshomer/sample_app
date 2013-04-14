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

	describe "methods" do
		it { should respond_to(:name) }
		it { should respond_to(:email) }
		it { should respond_to(:password_digest) }
		it { should respond_to(:password) }
	  it { should respond_to(:password_confirmation) }
	  it { should respond_to(:authenticate)}
	  it { should respond_to(:remember_token) }
	  it { should respond_to(:admin) }
	  it { should respond_to(:microposts) }
	  it { should respond_to(:feed) }
	  it { should respond_to(:relationships) }
	  it { should respond_to(:followed_users) }
	  it { should respond_to(:reversed_relationships) }
	  it { should respond_to(:followers) }
	  it { should respond_to(:follow!) }
	  it { should respond_to(:unfollow!) } 
	  it { should respond_to(:messages) } #messages sent by the user
	  it { should respond_to(:recieved_messages) }
	end

	it { should be_valid } 
	it { should_not be_admin }

	describe "valid data" do
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

	describe "microposts association" do
		before { @user.save }
		let!(:older_mp) do
			FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
		end
		let!(:newer_mp) do
			FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
		end

		it "should return microposts in reversed order" do
			@user.microposts.should==[newer_mp, older_mp]			
		end

		it "should destroy associated microposts" do
			microposts=@user.microposts.dup
			@user.destroy
			microposts.should_not be_empty
			microposts.size.should==2
			microposts.each do |micropost|
				Micropost.find_by_id(micropost.id).should be_nil
				lambda do
					Micropost.find(micropost.id)
				end.should raise_error(ActiveRecord::RecordNotFound)
			end								
		end
		describe "feed" do
			let(:unfollowed_user) { FactoryGirl.create(:user) }
			let(:unfollowed_post) { FactoryGirl.create(:micropost, user: unfollowed_user) }
			let(:followed_user) { FactoryGirl.create(:user) }
			let(:followed_post) { FactoryGirl.create(:micropost, user:followed_user, content: "foo") }
			before(:each) do
				@user.follow!(followed_user)
				3.times {|x| FactoryGirl.create(:micropost, user: followed_user, content: "fake post #{x}")}
			end
			its(:feed) { should include(newer_mp) }
			its(:feed) { should include(older_mp) }
			its(:feed) { should_not include(unfollowed_post) }
			its(:feed) { should include(followed_post)}
			its(:feed) do
				followed_user.microposts.each do |micropost|
					should include(micropost)
				end
			end
		end
	end

	describe "replies" do			
		let!(:first_user) { FactoryGirl.create(:user) }
		let!(:post_by_first) { FactoryGirl.create(:micropost, user: first_user, 
																											content: "post by first user") }
		let!(:other_user) { FactoryGirl.create(:user) }
		let!(:post_by_other) { FactoryGirl.create(:micropost, 
																										user: other_user,
																								 content: "post by other user") }
		let!(:reply_post) { FactoryGirl.create(:micropost,	 user: first_user,
																										 	content: "reply by first user to post by other user",
																									in_reply_to: other_user.id) }	
		let!(:follower) { FactoryGirl.create(:user) }

		before { follower.follow!(first_user) }
		it "should be included in the feed of the replying user" do
			first_user.feed.should include(reply_post)
			first_user.feed.should include(post_by_first)
		end
		it "should be included in the feed of the replied to user" do
			other_user.feed.should include(reply_post)	
		end
		it "should not be included in followers of the replying user that are not the replied to user" do
			follower.feed.should include(post_by_first)		
			follower.feed.should_not include(reply_post)		
		end
	end

	describe "relationships" do
		let(:followed) {FactoryGirl.create(:user)}
		before(:each) do			
			@user.save
			@user.follow!(followed)
		end		
		describe "following" do
			it { should be_following(followed) }
			its(:followed_users) { should include(followed) }					
		end
		describe "unfollowing" do
			before { @user.unfollow!(followed) }
			it { should_not be_following(followed) }
			its(:followed_users) { should_not include(followed) }			
		end

		describe "followers" do
			subject{followed}
			it { should be_followed(@user) }
			its(:followers) { should include(@user) }			
		end
	end

  describe "upon following" do
    let!(:user) { FactoryGirl.create(:user) } 
    let!(:follower) { FactoryGirl.create(:user) }
    it "should send an email" do
      lambda do
        follower.follow!(user)
        sleep (0.00001).second
      end.should change(Mailer.deliveries, :count).by(1)
    end
    describe "should send an email with the right parameters" do
      subject {Mailer.deliveries.last}
      before(:each) do
        follower.follow!(user)  
  			sleep (0.00001).second      
      end      
      its(:to) { should == []<< user.email }
      its(:subject) { should=="#{follower.name} is now following you" }     
      its(:body) { should =~ /stop receiving/ }
    end    
  end
end 
