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

  # attributes
  attr_accessible :email, :name, :password, :password_confirmation
  attr_protected  :admin
  has_secure_password
  has_many :microposts, dependent: :destroy # associated microposts should be destroyed when the user is destroyed

  # relationships
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy  # Rails expects the foreign key to be of the form <class>_id, in this case, users are identified as followers, hence we have to specify follower_id as the foreign key
                                                                            # destroying a user should destroy all the relationships
  # A user is following many users, has many followed_users => User - [user_id] == Relationship - [follower_id]
  has_many :followed_users, through: :relationships, source: :followed # has many followed users, through the relationships model, source: :followed <- this is the foreign key, the source of followed_users is the set of followed ids
  
  has_many :reverse_relationships,  foreign_key: "followed_id", 
                                    class_name: "Relationship", 
                                    dependent: :destroy
  # A user has many followers => User - [user_id] == Relationship - [followed_id] 
  # Have to include the class name, or Rails will look for a ReverseRelationship class, which does not exist
  has_many :followers, through: :reverse_relationships, source: :follower
  

  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token
#  before_save { email.downcase! }
  validates(:name, presence: true, length: { maximum: 50} )    #   checks to see if the User has a valid name
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates(:email, presence: true, format: { with: VALID_EMAIL_REGEX}, uniqueness: { case_sensitive: false } )   #   checks to see if the User has a valid email
  validates(:password, presence: true, length: { minimum: 6 } )
  validates_confirmation_of :password
  validates :password_confirmation, presence: true

  # methods
  def following?(other_user)
    relationships.find_by_followed_id(other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by_followed_id(other_user.id).destroy
  end

  def feed
    Micropost.from_users_followed_by(self)
  end

  private
    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64   # Using self ensures that assignment sets the user’s remember_token so that it will be written to the database along with the other attributes when the user is saved.
    end
end
