require 'spec_helper'

describe "User Pages" do
  subject { page }

  # Index
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


  # Signup Page #
  describe "signup page" do
    before { visit signup_path }
    it { should have_selector('h1',     text: 'Sign up') }
    it { should have_selector('title',  text: full_title('Sign up'))}
  end

  # Profile Page #
  describe "profile page" do
    # Code to make a user variable
    let(:user) { FactoryGirl.create(:user) }
    # Create test microposts
    let!(:micropost1) { FactoryGirl.create(:micropost, user: user, content: "Micropost 1 Foo") }
    let!(:micropost2) { FactoryGirl.create(:micropost, user: user, content: "Micropost 2 Foo") }

    before { visit user_path(user)}

    it { should have_selector('h1', text: user.name) }
    it { should have_selector('title', text: user.name) }

    describe "should show microposts" do
      # it should show all the microposts and also the total number of microposts
      it { should have_content(micropost1.content) }
      it { should have_content(micropost2.content) }
      it { should have_content(user.microposts.count) }
    end

    # test for follow/unfollow button
    describe "follow/unfollow buttons" do
      let(:other_user) { FactoryGirl.create(:user) }

      # log in as user
      before { sign_in user }

      # Following a user
      describe "following a user" do
        before { visit user_path(other_user) }

        # when following a user, the number of followed users should increase +1
        it "should increase the number of user's followed users by 1" do
          expect do
            click_button "Follow"
          end.to change(user.followed_users, :count).by(1)
        end

        # when following a user, the number of followers for the other_user should increase +1
        it "should increase the number of followers of the other_user by 1" do
          expect do
            click_button "Follow"
          end.to change(other_user.followers, :count).by(1)
        end

        # the follow/unfollow button should toggle
        describe "toggling the button" do
          before { click_button "Follow" }
          it { should have_selector('input', value: "Unfollow") }
        end
      end

      # Unfollowing a user
      describe "unfollowing a user" do
        before do
          user.follow!(other_user)
          visit user_path(other_user)
        end

        # when following a user, the number of followed users should increase +1
        it "should decrease the number of user's followed users by 1" do
          expect do
            click_button "Unfollow"
          end.to change(user.followed_users, :count).by(-1)
        end

        # when following a user, the number of followers for the other_user should increase +1
        it "should decrease the number of followers of the other_user by 1" do
          expect do
            click_button "Unfollow"
          end.to change(other_user.followers, :count).by(-1)
        end

        # the follow/unfollow button should toggle
        describe "toggling the button" do
          before { click_button "Unfollow" }
          it { should have_selector('input', value: "Follow") }
        end
      end
    end
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

  # Following and Followers Page #
  describe "following/followers" do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    before { user.follow!(other_user) } # user will follow the other_user

    # For signed-in users, the pages should have the links for following and followers
    describe "followed users" do
      before do
        sign_in user
        visit following_user_path(user)
      end

      it { should have_selector('title', text: full_title('Following')) }
      it { should have_selector('h3', text: 'Following') }
      it { should have_link(other_user.name, href: user_path(other_user)) }
    end

    # For signed-in users, the pages should have the links for following and followers
    describe "followers" do
      before do
        sign_in other_user
        visit followers_user_path(other_user)
      end

      it { should have_selector('title', text: full_title('Followers')) }
      it { should have_selector('h3', text: 'Followers') }
      it { should have_link(user.name, href: user_path(user)) }
    end
  end
end