  require 'spec_helper'

  describe UsersController do 

  	render_views

    describe "Get new" do 
  		it "should be successful" do
  			get :new
  			response.should be_success
  		end		
  	end

  	it "should have the right title" do
  		visit signup_path
  		page.should have_selector('title',text: "Sign Up")
  	end 

    describe "Edit" do 
    	subject { page }
      let(:user) { FactoryGirl.create(:user) }
      before do 
       test_sign_in user 
       visit edit_user_path(user)  
      end
      
      describe "page" do
        it { should have_selector('title', text: "Edit user") }
        it { should have_selector('h1', text: "Update your profile") }
        it { should have_link('change', href: 'http://gravatar.com/emails', 
                                      target: "_blank") } # doesn't actually test the _blank
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
        it { should have_selector('div.alert.alert-success', text: /data was sucessfully updated/i) }
        it { should have_link('Sign out', href: signout_path) }
        
        specify { user.reload.name.should == new_name }
        specify { user.reload.email.should == new_email }       
      end
    end    

    describe "authentication of edit/update actions" do
      subject { page }
    	let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, name: "Wrong User", email: "wrong@example.com") }

    	describe "for users that are not yet signed in" do
        it "should deny access to 'edit' and redirect to signin" do
          get :edit, id: user
          response.should redirect_to(signin_path)  
          flash[:notice].should =~ /sign in/i    
        end

        it "should deny access to 'update' and redirect to signin" do
          put :update, id: user, user: {}
          response.should redirect_to(signin_path)      
          flash[:notice].should =~ /sign in/i
        end

        it "should deny access to the users list and redirect to signin" do
          get :index
          response.should redirect_to(signin_path)      
          flash[:notice].should =~ /sign in/i
        end

        it "should denty access to the followers page" do
          get :followers, id: 1
          response.should redirect_to(signin_path)
        end

        it "should denty access to the following page" do
          get :following, id: 1
          response.should redirect_to(signin_path)
        end
      end
      

      describe "friendly forwarding" do
        it "should redirect to the edit page after immediate signin if correct user" do    
          visit edit_user_path(user)
          fill_in "Email",    with: user.email 
          fill_in "Password", with: user.password 
          click_button 'Sign in'    
          response.should render_template('users/edit')
        end     

        it "should redirect to the root after signin if wrong user" do          
          visit edit_user_path(user)
          fill_in "Email",    with: wrong_user.email
          fill_in "Password", with: wrong_user.password 
          click_button 'Sign in'    
          # page.should have_selector('h1',text: /to the sample app/i)
          response.should render_template('static_pages/home')
        end

        describe "after a failed attempt to sign in" do
          before do
            visit users_path
            fill_in "Email",    with: "despicable@me.com"
            fill_in "Password", with: user.password 
            click_button 'Sign in'  
            fill_in "Email",    with: user.email
            fill_in "Password", with: user.password 
            click_button 'Sign in'      
          end
          it "should redirect to the user's profile page" do                
            page.should render_template "users/show"
            page.should have_selector('h1', text: user.name)                    
          end        
          specify {current_path.should==user_path(user) }
        end
      end
      
      describe "for signed in users" do

        before { test_sign_in user } 

        describe "attempting to edit their own settings" do
          before { visit edit_user_path(user) }
          it { should have_selector('title', text: "Edit user") }
          it { should have_selector('h1', text: "Update your profile") }   
          it { should have_selector('input#user_name') }
          it { should have_selector('input#user_email') }
          it { should have_selector('input#user_password') }
          it { should have_selector('input#user_password_confirmation') }
          it { should have_selector('input#user_recieve_notifications') }
        end

        describe "attempting to edit another user's settings" do
          before { visit edit_user_path(wrong_user) }
          it { should_not have_selector('title', text: "Edit user") }
          it { should_not have_selector('h1', text: "Update your profile") }    

          it "should denty access to 'edit' and redirect to root" do
            # page.should have_selector('h1',text: /to the sample app/i)  
            response.should render_template('static_pages/home')         
          end

          it "should deny access to 'update' and redirect to root" do
            put :update, id: wrong_user, user: {}
            # page.should have_selector('h1',text: /to the sample app/i)
            response.should redirect_to(root_path)
          end     
        end

        before { controller.sign_in user }
        it "should deny access to 'new' and redirect to root" do
          get :new
          response.should redirect_to(root_path)             
        end  

        it "should deny access to 'new' and redirect to root" do
          post :create, user: {}
          response.should redirect_to(root_path)             
        end  

        describe "for signed in non-admins" do      
        let(:non_admin) { FactoryGirl.create(:user) }
        before { controller.sign_in(user) }
          it "attempting to submit a delete request to the destroy action" do
            delete :destroy, id: non_admin 
            response.should redirect_to(root_path)                 
          end
        end
      end
    end 
    
    describe "specify and controller variables" do
      let(:user) { FactoryGirl.create(:user)}    
      before { controller.sign_in(user) }
      specify { controller.signed_in?.should be_true }
      specify { controller.current_user.email.should == user.email }
      specify { cookies['remember_token'].should == user.remember_token }
      describe "GET index" do
        it "should assign current_user to the current user" do
          get :index
          assigns(:current_user).should == user          
        end
      end      
      # specify { cookies['set_cookies'].should be_nil }
      # specify { cookies.should be_nil }      
      
      # describe "cookiess" do
      #   before { visit user_path(user) }         
      #   specify {response.headers.should be_nil}
      # end   

      describe "signing out" do
        before { controller.sign_out }
        specify { controller.signed_in?.should be_false }         
      end   
    end
  end
