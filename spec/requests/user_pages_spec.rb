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
        it "should send a verification email" do
          expect {click_button submit}.to change(Mailer.deliveries, :count).by(1)
        end
        describe "submitting the form" do
          before { click_button submit }          
          let!(:user) { User.find_by_email("example@example.com") }
          describe "should send a verification email with correct content" do            
          subject {Mailer.deliveries.last}      
          
          its(:to) { should == []<< user.email }
          its(:subject) { should =~ /email verification for/ }
            it "and the right body" do
              Mailer.deliveries.last.html_part.body.should =~
               /to verify your email address and activate your account please click/i   
              Mailer.deliveries.last.html_part.body.should have_selector('b', text: user.name)                 
              Mailer.deliveries.last.html_part.body.should =~ /#{user.email_verification.token}/  
              Mailer.deliveries.last.html_part.body.should have_link("Activate my account")                 
            end
          end
          describe "should not be signed in" do                 
            it { should_not have_link('Sign out',href: signout_path) }
            it { should have_link('Sign in',href: signin_path) }
            it { should have_selector('div.alert.alert-success',
             text: /verification email was sent to #{user.email}/i) }
            it { should have_selector('h1', text: /welcome/i) } 
            describe 'However, clicking the email verification link should sign the user in' do                          
              before(:each) do              
                visit edit_email_verification_path(user.email_verification.token)
              end                        
              it { should have_selector('div.alert.alert-success', text: /your email was verified/i) }
              it { should have_link('Sign out',href: signout_path) }
              it { should_not have_link('Sign in',href: signin_path) }
            end                      
          end           
        end           
      end
    end
  end

  describe "signing in" do
    let!(:user) { FactoryGirl.create(:user, active: false) }
    before do
      visit signin_path      
      fill_in "Email",            with: user.email
      fill_in "Password",         with: "foobar"      
      click_button 'Sign in'       
    end  
    describe "before verification of email address" do
      it { should_not have_link('Sign out', href: signout_path) }
      it { should have_link('Sign in', href: signin_path) }
      it { should have_selector('div.alert.alert-error', 
                              text: "Please click the activation link sent to #{user.email}") }
      specify { current_path.should == root_path }
    end
    describe "after verification of email address" do
      let!(:ev) { FactoryGirl.create(:email_verification, user: user) }
      before { visit edit_email_verification_path(user.email_verification.token) }
      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }  
      it { should have_selector('div.alert.alert-success', text: "#{user.name}, your email was verified") }
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
        test_sign_in FactoryGirl.create(:user, active: true)
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

        it "should list the number of microposts for each user" do
          User.all.each do |user|
            page.should have_selector('td#micropost_count',
                                       text: "#{user.microposts.count} microposts")
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
        describe "search" do
          it { should have_selector('input#search') }          
          it { should have_selector('input#users_search_button', value: "Search") }
          describe 'should not filter on empty search' do
          before(:all) { 30.times {FactoryGirl.create(:user)}  }
          after(:all) { User.delete_all }
          before { click_button 'Search' }
          it { should have_selector('div.pagination') }          
          end

          describe "should find a user by name" do
            let!(:marlon) { FactoryGirl.create(:user, name: 'Marlon Brando', email: 'marlon@holliwood.com') }
            let!(:barack) { FactoryGirl.create(:user, name: 'Barack Obama', email: 'barack@president.gov') }
            let!(:bill) { FactoryGirl.create(:user, name: 'Bill Clinton', email: 'billwaspresident@monica.xxx') }
            let!(:marlo) { FactoryGirl.create(:user, name: 'Marlo Stanfield', email: 'marlo@wire.org') }
            before do
              fill_in 'search', with: 'marlo a.x'
              click_button 'Search'
            end
            it "should find marlon, marlo and bill" do
              page.should have_selector('li', text: marlon.name)
              page.should have_link 'Email' , href: "mailto:#{marlon.email}"
              page.should have_link(marlon.name, href: user_path(marlon.id))
              page.should have_selector('li', text: marlo.name)
              page.should have_link 'Email' , href: "mailto:#{marlo.email}"
              page.should have_link(marlo.name, href: user_path(marlo.id))
              page.should have_selector('li', text: bill.name)
              page.should have_link 'Email' , href: "mailto:#{bill.email}"
              page.should have_link(bill.name, href: user_path(bill.id))              
            end
            it "should not find barack" do
              page.should_not have_selector('li', text: barack.name)
              page.should_not have_link 'Email' , href: "mailto:#{barack.email}"
              page.should_not have_link(barack.name, href: user_path(barack.id))                
            end            
          end
        end        
      end
      
      describe "delete links" do
        describe "as admin user" do
          let(:admin) { FactoryGirl.create(:user, admin: true) }
          let(:nonadmin) { FactoryGirl.create(:user) }
          before(:each) do
            click_link 'Sign out'
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
  
  describe "following/followers" do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    before { user.follow!(other_user) }

    describe "following page for signed in user" do
     before(:each) do
       test_sign_in user
       visit following_user_path(user)
     end
      it { should have_selector('title', text: 'Following') }
      it { should have_selector('h3',text: 'Following') }
      it { should have_link(other_user.name, href: user_path(other_user)) }
    end

    describe "followers page for signed in user" do
     before(:each) do
       test_sign_in other_user
       visit followers_user_path(other_user)
     end
      it { should have_selector('title', text: 'Followers') }
      it { should have_selector('h3',text: 'Followers') }
      it { should have_link(user.name, href: user_path(user)) }
    end 
  end

  describe "profile page" do
    
    subject {page}
    describe "access" do
      describe "for non-admin" do
        let(:user) { FactoryGirl.create(:user) }  
        before(:each) do
          test_sign_in user
          visit user_path(user)
        end

        it { should have_selector('h1', text: user.name) }
        it { should have_selector('title', text: user.name) }
        it { should_not have_link('view my profile') }
      end

      describe "for admins" do
        let(:admin) { FactoryGirl.create(:user, admin: true) }  
        before(:each) do
          test_sign_in admin
          visit user_path(admin)
        end
        it { should have_selector('div.administrator', text: "(administrator)") }      
      end 
    end

    describe "followers/following links" do
      describe "for current user" do
        let!(:user) { FactoryGirl.create(:user) }
        before(:each) do
          test_sign_in user
          visit user_path(user)
        end
        it { should have_link("#{user.followed_users.count} following",
         href: following_user_path(user)) }
        it { should have_link("#{user.followers.count} followers", 
          href: followers_user_path(user)) }
      end 
      describe "for other users" do
        let!(:user) { FactoryGirl.create(:user) }
        let!(:other_user) { FactoryGirl.create(:user) }
        before(:each) do
          test_sign_in user
          visit user_path(other_user)
        end
        it { should_not have_link("#{other_user.followed_users.count} following", 
                                  href: following_user_path(other_user)) }
        it { should_not have_link("#{other_user.followers.count} followers", 
                                  href: followers_user_path(other_user)) }
        it { should have_content("#{other_user.followed_users.count} following") }
        it { should have_content("#{other_user.followers.count} followers") }
      end
    end
      
    describe "microposts list" do
      let(:user) { FactoryGirl.create(:user) }
      describe "layout" do
        
        let!(:mp1) { FactoryGirl.create(:micropost, user: user, content: "foo bar") }
        let!(:mp2) { FactoryGirl.create(:micropost, user: user, content: "baz quux") }      
        
        before(:each) do        
          test_sign_in user
          visit user_path(user)
        end
        it { should have_selector('li', text: mp1.content) }
        it { should have_selector('li', text: mp2.content) }
        it { should have_selector('span.content', text: mp1.content) }
        it { should have_selector('span.content', text: mp2.content) }       
        it { should have_content user.microposts.count }  
        it { should_not have_selector('div.pagination') }     
        it { should have_link('delete', href: micropost_path(mp1)) }    
 
      end

      describe "with pagination" do
        
        15.times {|n| let!(:"mipo#{n}") { FactoryGirl.create(:micropost,
                                                             user: user, content: "foobazquux")} }
        before(:each) do        
          test_sign_in user
          visit user_path(user)
        end  

        it { should have_selector('div.pagination') }         
      end 
    end

    describe "follow/unfollow buttons" do
      let(:follower) { FactoryGirl.create(:user) }
      let(:followed) { FactoryGirl.create(:user) }
      let!(:other_followed) { FactoryGirl.create(:user) }
      before(:each) do
        test_sign_in(follower)
        visit user_path(followed)        
      end
      it { should have_selector('input#Follow_button') }
      describe "clicking on the 'Follow' button" do        
        it "should increase the list of followed users of the follower by 1" do
          expect do
            click_button 'Follow'
            page.should have_selector('h1', text: followed.name)
          end.to change(follower.followed_users, :count).by(1)
        end        
        it "should increase the list of followers of the followed user by 1" do
          expect do
            click_button 'Follow'
          end.to change(followed.followers, :count).by(1)
        end
        describe "notification" do          
          it "should be sent" do
            expect do
              click_button 'Follow'              
            end.to change(Mailer.deliveries, :count).by(1)
          end                
        end      
        describe "should toggle the button" do
          before { click_button 'Follow' }
          it { should have_selector('input#Unfollow_button') }
        end
        describe "notification email" do
          before(:each) do            
            click_button 'Follow'           
          end
          it "should have right parameters" do
            Mailer.deliveries.last.to.should == []<<followed.email
            Mailer.deliveries.last.subject.should =~ /#{follower.name} is now following you/
            Mailer.deliveries.last.from.should ==  []<<"me@sample.app"
            Mailer.deliveries.last.html_part.body.should =~ /#{follower.name} is now following you/
          end
        end        
      end
      describe "clicking on the 'Unfollow' button" do  
        before(:each) do
          follower.follow!(followed)
          visit user_path(followed)                  
        end
        it "should increase the list of followed users of the follower by 1" do
          expect do
            click_button 'Unfollow'
          end.to change(follower.followed_users, :count).by(-1)
        end
        it "should increase the list of followers of the followed user by 1" do
          expect do
            click_button 'Unfollow'                     
          end.to change(followed.followers, :count).by(-1)
        end
       
        describe "notification" do           
          it "should be sent" do
            expect do
              click_button 'Unfollow'                   
            end.to change(Mailer.deliveries, :count).by(1)
          end                 
        end             
        describe "should toggle the button back" do
          before { click_button 'Unfollow' }
          it { should have_selector('input#Follow_button') }
        end
        describe "notification email" do
          before(:each) do            
            click_button 'Unfollow'
            
          end
          it "should have right parameters" do
            Mailer.deliveries.last.to.should == []<<followed.email
            Mailer.deliveries.last.subject =~ /"#{follower.name} is no longer following you"/
            Mailer.deliveries.last.from ==  []<<"me@sample.app"
          end
        end         
      end 
    end

    describe "opted out users should not recieve notifications" do
      let!(:follower) { FactoryGirl.create(:user) }
      let!(:followed) { FactoryGirl.create(:user) }
      before do
        followed.toggle(:recieve_notifications)
      end
      it "from users starting to follow them" do
        expect do
          follower.follow!(followed)
          sleep 1.second
        end.not_to change(Mailer.deliveries, :count)
      end
      it "from users stopping to follow them" do
        expect do
          follower.follow!(followed)          
          follower.unfollow!(followed)          
        end.not_to change(Mailer.deliveries, :count)
      end      
    end

    describe "message button and form" do
      let!(:sender) { FactoryGirl.create(:user) }
      let!(:recipient) { FactoryGirl.create(:user) }
      before(:each) do
        test_sign_in sender
        recipient.follow!(sender)
        visit user_path(recipient)
      end
      it { should have_selector('textarea#message_content', text: "")}
      it { should have_selector('input#Send_button', title: 'Send') }      

      describe "message creation" do
        describe "with invalid data" do
          it "clicking the button should not increse message count" do
            expect {click_button 'Send'}.not_to change(Message, :count).by(1)
          end
          describe "error message" do
            before { click_button 'Send' }
            it { should have_selector('div.alert.alert-error', text: 'error') }
          end
        end
        describe "with valid data" do
          before { fill_in "message_content", with: "test message from #{sender.name}" }
          it "clicking it should increse sender message count" do
            expect do
              click_button 'Send'              
            end.to change(Message, :count).by(1)
          end
          describe "should redirect to the sender's messages page" do
            before { click_button 'Send' }
            it { should have_selector('h2', text: " for #{sender.name}") }
            describe "and show the new message on the messages page" do
              it { should have_selector('span.message',
               text: "test message from #{sender.name}") }
              it { should have_selector('span.timestamp', 
                                          text: "from #{sender.name} to #{recipient.name}") }
            end
          end
          describe "should show a success flash" do
            before { click_button 'Send' }
            it { should have_selector('div.alert.alert-success', 
              text: "Direct message sent successfuly to #{recipient.name}") }
          end
        end
      end

      describe "for non followers" do
        before do 
          recipient.unfollow!(sender)
          visit user_path(recipient)
        end
        it { should_not have_selector('textarea#message_content', text: "")}
        it { should_not have_selector('input#message_button') }
      end      
    end
  end
end  

