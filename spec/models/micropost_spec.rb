require 'spec_helper'

describe Micropost do

  let(:user) { FactoryGirl.create(:user) }
  # Test that the Micropost model responds to the attributes: content, user_id

  before { @micropost = user.microposts.build(content: "Lorem ipsum") }

  subject { @micropost }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user)    }  # A micropost should be associated with a user. Micropost.user should work
  its(:user) { should == user }       # The result returned by micropost.user should be the same as the User created

  it { should be_valid }

  # A micropost should not allow access to its user_id
  describe "accessible attributes" do
    it "should not allow access to user_id" do
      expect do
        Micropost.new(user_id: user.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  # A micropost cannot be created without a valid user
  describe "when user_id is not present" do
    before { @micropost.user_id = nil }
    it { should_not be_valid }
  end

  # A micropost cannot have blank content"
  describe "a micropost cannot have blank content" do
    before { @micropost.content = " " }
    it { should_not be_valid }
  end

  # A micropost cannot be more than 140 chars"
  describe "a micropost cannot have more than 140 chars" do
    before { @micropost.content = "a" * 141 }
    it { should_not be_valid }
  end

end

