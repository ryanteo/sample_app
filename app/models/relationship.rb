class Relationship < ActiveRecord::Base
  attr_accessible :followed_id
  # A relationship belongs to both followers and followed
  belongs_to :follower, class_name: "User" # use belongs_to, but need to supply the class name "Users" for Rails
  belongs_to :followed, class_name: "User"

  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
