require 'spec_helper'

describe "MessagePages" do
	let!(:sender) { FactoryGirl.create(:user) }
	let!(:recipient) { FactoryGirl.create(:user) }	
  subject {page}
  before(:each) do
    test_sign_in(sender)
    recipient.follow!(sender)
    @msg_1= FactoryGirl.create(:message,content: "message 1", sender: sender, recipient: recipient)
    @msg_2= FactoryGirl.create(:message,content: "message 2", sender: sender, recipient: recipient)
    visit messages_path
  end

  describe "layout" do
  	it { should have_selector('h1', text: "Messages") }
  	it { should have_selector('title', text: full_title('Messages')) }
  end

  describe "should list all the messages sent by the current user" do
    it { should have_selector('li', text: @msg_1.content) }
    it { should have_selector('li', text: @msg_2.content) }
    it { should have_selector('span.message', text: @msg_1.content) }
    it { should have_selector('span.timestamp', text: @msg_1.recipient.name) }
    it { should have_selector('span.message', text: @msg_2.content) }       
    it { should have_content "#{sender.messages.count} messages" }  
    it { should have_selector('div.pagination') }  
  end
end
