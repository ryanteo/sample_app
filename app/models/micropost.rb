class Micropost < ActiveRecord::Base
  attr_accessible :content
  # attr_protected  :user_id
  belongs_to :user # A micropost should belong to a User

  validates :content, presence: true, length: { maximum: 140 }
  validates :user_id, presence: true
  
  default_scope order: 'microposts.created_at DESC'

  def self.from_users_followed_by(user)
    # push the query to SQL, where subselect is faster
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id",
          user_id: user.id)
    
#    followed_user_ids = user.followed_user_ids
#    where("user_id IN (:followed_user_ids) OR user_id = :user_id", 
#      followed_user_ids: followed_user_ids, user_id: user)

  end
end





