FactoryBot.define do
  factory :account do
    association :team
    name { "MyString" }
    mastodon_handle { "MyString" }
    twitter_handle { "MyString" }
    area_of_focus { "MyString" }
    where_to_publish { "MyString" }
    description { "MyString" }
  end
end
