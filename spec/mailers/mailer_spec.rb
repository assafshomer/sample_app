require "spec_helper"
include TestUtilities

describe Mailer do   
  # let!(:address) { "a@b.c" }
  let!(:address) { fake_address }
  let!(:subject) { "test email #{fake_subject}" }
  before do    
    Mailer.prepare_email(address, subject).deliver
    # sleep (0.001).second
  end

  it "should send an email with correct subject and to/from address" do
  	 Mailer.deliveries.last.subject.should == subject	     
     Mailer.deliveries.last.to.should == []<<address 
     Mailer.deliveries.last.from.should ==  []<<"me@sample.app"
  end

  it "should increment the deliveries array" do
  	lambda do  		
  		Mailer.prepare_email(address, subject).deliver
  	end.should change(Mailer.deliveries, :count).by(1)
  end
end
