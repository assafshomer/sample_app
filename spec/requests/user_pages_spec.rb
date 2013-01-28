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



  describe "users" do

    describe "no link before signing in" do
      before {visit root_path}
      it { should_not have_link 'Users', href: users_path }      
    end

    describe "list after signing in" do
      
      before(:each) do
        test_sign_in FactoryGirl.create(:user)
        FactoryGirl.create(:user, name: "Bob", email: "bob@example.com")
        FactoryGirl.create(:user, name: "Ben", email: "ben@example.com")        
      end

      describe "find link to list" do
        before {visit root_path}
        it { should have_link 'Users', href: users_path }              
      end

      describe "should have titles " do

        before { visit users_path }

        it { should have_selector('title', text: "All users") }
        it { should have_selector('h1', text: "Listing users") }
        it { should have_link 'New User', href: new_user_path }

        it "and should list all users" do
          User.all.each do |user|
          page.should have_selector('li',text: user.name)
          end         
        end 

        describe "pagination" do
          before(:all) { 30.times {FactoryGirl.create(:user)}  }
          after(:all) { User.delete_all }

          it { should have_selector('div.pagination') }
          it "should list all users" do
            User.paginate(page: 1, :per_page => 10).order('name').each do |user|
              page.should have_selector('li', text: user.name)
              page.should have_link 'Email' , href: "mailto:#{user.email}"
            end            
          end
          
        end
      end
      
    end    
  end
   
end  

