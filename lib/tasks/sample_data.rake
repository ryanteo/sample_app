#  Use Rake and Faker to create 100 fake users
namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_users
    make_microposts
    make_relationships
  end
end

def make_users
  # Create an admin user
  admin = User.create!(name:            "Example Admin User",
    email:                  "example@railstutorial.org",
    password:               "foobar",
    password_confirmation:  "foobar")
  admin.toggle!(:admin)

  99.times do |n|
    name     = Faker::Name.name
    email    = "example-#{n+1}@railstutorial.org"
    password = "password"
    User.create!(name:                  name,
      email:                  email,
      password:               password,
      password_confirmation:  password)
  end
end

def make_microposts
  users = User.all(limit: 10)
  50.times do
    content = Faker::Lorem.sentence(5)
    users.each { |user| user.microposts.create!(content: content) }
  end
end

def make_relationships
  users = User.all
  user = User.first
  followed_users = users[2..50] 
  followers = users[3..40]
  followed_users.each { |followed| user.follow!(followed) } # The first user will follow users 2 to 50
  followers.each { |follower| follower.follow!(user) } # The first user will have followers 3 to 40
end

