#  Use Rake and Faker to create 100 fake users
namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do

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
end
