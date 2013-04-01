include ApplicationHelper

def valid_signin(user)
  fill_in "Email",    with: user.email 
  fill_in "Password", with: user.password 
  click_button "Sign in"
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = user.remember_token 
end

def sign_in(user)
  visit signin_path
  valid_signin(user)
end

def valid_update_profile(user)
  fill_in "Name",             with: user.name
  fill_in "Email",            with: user.email 
  fill_in "Password",         with: user.password
  fill_in "Confirmation",     with: user.password
  click_button "Save changes"
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-error', text: message)
  end
end

