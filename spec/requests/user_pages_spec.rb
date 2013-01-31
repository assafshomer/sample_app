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

  describe "Index" do

    describe "before signing in" do
      describe "no link on header" do
        before {visit root_path}
        it { should_not have_link 'Users', href: users_path }    
      end
      describe "deny access to users index" do
        before { visit users_path }
        it { should have_selector('title', text: "Sign in")}
        
        it "should deny access to users index" do
          get 'users'
          response.should redirect_to(signin_path)          
        end
      end 
    end

   

    describe "list after signing in" do
      
      before(:each) do
        test_sign_in FactoryGirl.create(:user)
        FactoryGirl.create(:user, name: "Bob", email: "bob@example.com")
        FactoryGirl.create(:user, name: "Ben", email: "ben@example.com")        
      end

      describe "find link to users list" do
        before {visit root_path}
        it { should have_link 'Users', href: users_path }              
      end

      describe "list layout " do

        before { visit users_path }

        it { should have_selector('title', text: "All users") }
        it { should have_selector('h1', text: "Listing users") }
        it { should have_link 'New User', href: new_user_path }
        it { should_not have_link 'delete' }

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
              page.should have_link(user.name, href: user_path(user.id))
            end             
          end          
        end        
      end
      
      describe "delete links" do
        describe "as admin user" do
          let(:admin) { FactoryGirl.create(:user, admin: true) }
          let(:nonadmin) { FactoryGirl.create(:user) }
          before(:each) do
            test_sign_in admin
            visit users_path
          end
          it "should be present for all *other* users" do
            User.all.each do |user|
              page.should have_link 'delete', href: user_path(user) unless user==admin  
              page.should_not have_link 'delete', href: user_path(user) if user==admin      
            end
          end

          it "should delete the user" do
            expect {click_link('delete')}.to change(User, :count).by(-1)            
          end

          it "redirect to the users list and flash if successfuly deleted the user " do
            click_link('delete')
            page.should have_selector('h1' , text: "Listing users")
            page.should have_selector('div.alert.alert-success', text: "deleted")
          end
        end
      end

    end    
  end
  


end  

