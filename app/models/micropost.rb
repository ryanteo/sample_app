class Micropost < ActiveRecord::Base
  attr_accessible :content
  # attr_protected  :user_id
  belongs_to :user # A micropost should belong to a User

  validates :content, presence: true, length: { maximum: 140 }
  validates :user_id, presence: true
  
  default_scope order: 'microposts.created_at DESC'
end

