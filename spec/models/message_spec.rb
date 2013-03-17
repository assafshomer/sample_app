require 'spec_helper'

describe Message do
  let(:sender) { FactoryGirl.create(:user) }
  let!(:recipient) { FactoryGirl.create(:user) }
  before do
  	recipient.follow!(sender)
    @message=sender.messages.create(content: "Lorem ipsum", recipient_id: recipient.id)
  end

  subject {@message}

  it { should respond_to(:content) }
  it { should respond_to(:sender_id) }
  it { should respond_to(:sender) }
  it { should respond_to(:recipient_id) } 
  it { should respond_to(:recipient) } 

  its(:sender_id) { should==sender }
  its(:recipient_id) { should==recipient }

  describe "validations: " do
  	describe "content" do
  		describe "should not be blank" do
  			before { @message.content="" }
  			it { should_not be_valid }  	
  		end
			describe "should not exceed 140 characters" do
				before { @message.content="a"*141 }
				it { should_not be_valid }				
			end
  	end
  	describe "sender id should not be nil" do
  		before { @message.sender_id=nil }
  		it { should_not be_valid }
  	end
  	describe "recipient_id should not be nil" do
  		before { @message.recipient_id=nil }
  		it { should_not be_valid }
  	end
  	
  	describe "recipient must follow sender" do
  		describe "so default message should be valid" do
  			it { should be_valid }			
  		end		
  		describe "but if recipients stops following then should not be valid" do
  			before { recipient.unfollow!(sender) }
  			it { should_not be_valid }
  		end
  	end  	
  end

  describe "accessible attributes" do
  	it "-sender_id should not be mass assigned" do
  		expect do
  		  Message.new(content: "lorem", sender_id: 1)
  		end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)  		
  	end 
  end

	describe "recipient must be follower of sender" do
		specify {@message.recipient.following?(message.sender).should be_true}  		
	end

 end