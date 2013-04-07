require 'spec_helper'

describe "UserPages" do
  subject { page }

  # When visiting /users/, it should show a list of users (FactoryGirl to create 30 sample users)
  describe "index" do
    let(:user) { FactoryGirl.create(:user) }

    before(:each) do
      sign_in(user)
      visit users_path
    end

    it { should have_selector("title", text: 'All users') }
    it { should have_selector('h1', text: "All users") }

    # Test for pagination, page should show 30 users
    describe "pagination" do
      before(:all)  { 30.times { FactoryGirl.create(:user) } }
      after(:all)   { User.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          page.should have_selector('li', text: user.name)
        end
      end
    end

    # admin users should be able to delete users
    describe "delete links" do
      it { should_not have_link('delete') }

      # Create an admin user and sign in
      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end
        # Delete another non-admin user
        it { should have_link('delete', href: user_path(User.first)) }
        it 'should be able to delete another user' do
          expect { click_link('delete') }.to change(User, :count).by(-1)
        end

        # admin should not be able to able to delete his own account
        it { should_not have_link('delete', href: user_path(admin)) }
        it { expect { delete user_path(admin) }.not_to change(User, :count) }
      end
    end
  end

  describe "signup page" do
    before { visit signup_path }
    it { should have_selector('h1',     text: 'Sign up') }
    it { should have_selector('title',  text: full_title('Sign up'))}
  end

  describe "profile page" do
    # Code to make a user variable
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user)}

    it { should have_selector('h1', text: user.name) }
    it { should have_selector('title', text: user.name) }
  end

  describe "signup" do
    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
      describe "should show flash error messages when submitting a blank user" do
        before { click_button submit }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do
      before do
        fill_in "Name",           with: "Example User"
        fill_in "Email",          with: "user@example.com"
        fill_in "Password",       with: "foobar"
        fill_in "Confirm Password",   with: "foobar"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email('user@example.com')}

        it { should have_selector('title', text: user.name) }
        it { should have_selector('div.alert.alert-success', text: "Welcome")}
        it { should have_link('Sign out')}
      end

    end
  end

  
  describe "edit" do
    let(:user) { FactoryGirl.create(:user)}
    before do
      sign_in user  #   user must sign in before they can edit profile
      visit edit_user_path(user)
    end

    describe "page" do 
      it {should have_selector('h1', text: "Update your profile")}
      it {should have_selector('title', text: "Edit user")}
      it {should have_link('change', href: "http://gravatar.com/emails")}
    end

    # there should be an error message for invalid submission
    describe "with invalid information" do
      before { click_button "Save changes"} 

      it { should have_content('error')}
    end

    describe "with valid information" do
      let(:new_name)  {"New Name"}
      let(:new_email) {"new@example.com"}
      before do
        fill_in "Name",           with: new_name
        fill_in "Email",          with: new_email
        fill_in "Password",       with: user.password
        fill_in "Confirm Password",   with: user.password
        click_button "Save changes"
      end

      it { should have_selector('title', text: new_name)}
      it { should have_selector('div.alert.alert-success')}
      it { should have_link('Sign out', href: signout_path)}
      specify { user.reload.name.should   == new_name }
      specify { user.reload.email.should  == new_email}
    end

  end

  # Signed-in users should not be able to access the #new and #create actions
#  describe "Signed-in users should not be able to access the #new and #create actions" do
#  let(:user) { FactoryGirl.create(:user) }
#  before do
#  sign_in user
#  visit signup_path
#  end
#  it { should have_content('You are currently signed in and cannot create new accounts.')}
#  end

  describe "Signed-in users" do
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in user} 

    describe "should not be able to access the #new user" do
      before { visit signup_path }
      it { should have_content('You are currently signed in and cannot create new accounts.')}
    end

# Can't access the create action as the user has to first visit the new page, redirect already happens at the new page
#    describe "should not access the #create action" do
#      before do
#        visit signup_path
#        click_button "Create my account"
#      end
#      it { should have_content('You are currently signed in and cannot create new accounts.')}
#    end
  end

end