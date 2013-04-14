FactoryGirl.define do
  factory :user do
    sequence(:name)            { |n| "Person #{n}" }
    sequence(:email)           { |n| "person_#{n}@railstutorial.org"}
    password                   "foobar"
    password_confirmation      "foobar"

    factory :admin do
      admin true
    end
  end

  factory :micropost do
    content "Some content for test micropost"
    user
  end
end
