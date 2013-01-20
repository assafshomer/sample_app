require 'spec_helper'

describe "User" do
  
  subject { page }

  describe "signup" do
    before { visit signup_path } 
    let(:submit) { "Create account" }      

    it { should have_selector('h1',    text: 'Sign Up') }
    it { should have_selector('title', text: full_title('Sign Up')) }

    describe "form submission with" do       

      describe "invalid data" do

        describe "empty form" do
          it "should not create a new user" do
            expect {click_button submit}.not_to change(User, :count)
          end 
          before {click_button submit}
          it { should have_selector('div#error_explanation') }         
        end

        describe "inavlid email submission" do
          before do
            fill_in "Name",             with: "assaf"  
            fill_in "Email",            with: "foo.bar"
            fill_in "Password",         with: "foobar"
            fill_in "Confirmation",     with: "foobar"          
          end
          it "should not create a new user" do
            expect {click_button submit}.not_to change(User,:count)              
          end             
        end   

        describe "password confirmation not matching" do
          before do
            fill_in "Name",             with: "assaf"  
            fill_in "Email",            with: "foo@bar.bax"
            fill_in "Password",         with: "foobar"
            fill_in "Confirmation",     with: "notmatching"          
          end
          it "should not create a new user" do
            expect {click_button submit}.not_to change(User,:count)  
          end       
        end 

        describe "no name" do
          before do
            fill_in "Name",             with: ""  
            fill_in "Email",            with: "foo@bar.bax"
            fill_in "Password",         with: "foobar"
            fill_in "Confirmation",     with: "foobar"          
          end
          it "should not create a new user" do
            expect {click_button submit}.not_to change(User,:count)  
          end       
        end  

        describe "no Email" do
          before do
            fill_in "Name",             with: "Example User"  
            fill_in "Email",            with: ""
            fill_in "Password",         with: "foobar"
            fill_in "Confirmation",     with: "foobar"          
          end
          it "should not create a new user" do
            expect {click_button submit}.not_to change(User,:count)  
          end       
        end 

        describe "no password" do
          before do
            fill_in "Name",             with: "Example User"  
            fill_in "Email",            with: "example@example.com"
            fill_in "Password",         with: ""
            fill_in "Confirmation",     with: "foobar"          
          end
          it "should not create a new user" do
            expect {click_button submit}.not_to change(User,:count)  
          end       
        end  

        describe "no confirmation" do
          before do
            fill_in "Name",             with: "Example User"  
            fill_in "Email",            with: "example@example.com"
            fill_in "Password",         with: "foobar"
            fill_in "Confirmation",     with: ""          
          end
          it "should not create a new user" do
            expect {click_button submit}.not_to change(User,:count)  
          end       
        end  

        describe "short password" do
          before do
            fill_in "Name",             with: "Example User"  
            fill_in "Email",            with: "example@example.com"
            fill_in "Password",         with: "f"
            fill_in "Confirmation",     with: "f"          
          end
          it "should not create a new user" do
            expect {click_button submit}.not_to change(User,:count)  
          end       
        end             

      end      
      
      describe "valid data" do 
        before do
              fill_in "Name",             with: "Example User"  
              fill_in "Email",            with: "example@example.com"
              fill_in "Password",         with: "foobar"
              fill_in "Confirmation",     with: "foobar"          
        end
        it "should create a new user" do
          expect {click_button submit}.to change(User,:count).by(1)  
        end   
        
        describe "should show flash" do
          before {click_button submit }
          let(:user) { User.find_by_email('example@example.com') }
          it { should have_selector('div.alert.alert-success') }  
        end

        describe "should be signed in" do
          before {click_button submit }
          it { should have_link('Sign out',href: signout_path) }
          it { should_not have_link('Sign in',href: signin_path) }
        end
              
      end

    end
  end

  describe "profile page" do
  
    let(:user) { FactoryGirl.create(:user) }  
    before { visit user_path(user) }

    it { should have_selector('h1', text: user.name) }
    it { should have_selector('title', text: user.name) }
  end

  describe "Edit" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit edit_user_path(user) }
    
    describe "page" do
      it { should have_selector('title', text: "Edit user") }
      it { should have_selector('h1', text: "Update your profile") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with inavlid information" do
      
      describe ": blank password and password confirmation" do
        before { click_button "Save changes" }  

        it { should have_content('This form has 3 errors') }        
      end

      describe ": blank form" do
        before do
          fill_in "Name",             with: ""  
          fill_in "Email",            with: ""
          click_button "Save changes"   
        end

        it { should have_content('This form has 6 errors') }        
      end
    end
    
    describe "with valid information" do
      let(:new_name) { "New Name" }
      let(:new_email) { "new@example.org" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirmation", with: user.password
        click_button "Save changes"
      end
        
      it { should have_selector('title', text: new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      
      specify { user.reload.name.should == new_name }
      specify { user.reload.email.should == new_email }       

    end
  end
  
end  

