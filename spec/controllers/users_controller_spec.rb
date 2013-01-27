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

	describe "profile page" do
  
    let(:user) { FactoryGirl.create(:user) }  
    before(:each) do
      test_sign_in user
      visit user_path(user)
    end

    it { page.should have_selector('h1', text: user.name) }
    it { page.should have_selector('title', text: user.name) }
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
      it { should have_selector('div.alert.alert-success', text: /data was sucessfully updated/i) }
      it { should have_link('Sign out', href: signout_path) }
      
      specify { user.reload.name.should == new_name }
      specify { user.reload.email.should == new_email }       

    end
  end


  describe "authentication of edit/update actions" do
  	let(:user) { FactoryGirl.create(:user) }
    let(:wrong_user) { FactoryGirl.create(:user, name: "Wrong User", email: "wrong@example.com") }

  	
    it "should denty access to 'edit" do
      get :edit, id: user
      response.should redirect_to(signin_path)  
      flash[:notice].should =~ /sign in/i    
    end

    it "should deny access to 'update'" do
      put :update, id: user, user: {}
      response.should redirect_to(signin_path)      
      flash[:notice].should =~ /sign in/i
    end


    it "should redirect to the edit page after signin if correct user" do    
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
      page.should have_selector('h1',text: /to the sample app/i)
    end

  end 

end
