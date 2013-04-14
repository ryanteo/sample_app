class CreateMicroposts < ActiveRecord::Migration
  def change
    create_table :microposts do |t|
      t.string :content
      t.integer :user_id

      t.timestamps
    end
    add_index :microposts, [:user_id, :created_at] # For us to retrieve all microposts associated with a given user id, Rails creates a multiple key index that uses both user_id and created_at
  end
end
