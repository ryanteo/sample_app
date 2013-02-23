# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation
  has_secure_password

  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token
#  before_save { email.downcase! }
  validates(:name, presence: true, length: { maximum: 50} )    #   checks to see if the User has a valid name
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates(:email, presence: true, format: { with: VALID_EMAIL_REGEX}, uniqueness: { case_sensitive: false } )   #   checks to see if the User has a valid email
  validates(:password, presence: true, length: { minimum: 6 } )
  validates_confirmation_of :password
  validates :password_confirmation, presence: true

  private
    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64   # Using self ensures that assignment sets the user’s remember_token so that it will be written to the database along with the other attributes when the user is saved.
    end


end
