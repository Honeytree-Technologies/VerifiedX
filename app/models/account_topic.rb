class AccountTopic < ApplicationRecord
  self.table_name = 'accounts_topics'
  belongs_to :account
  belongs_to :topic
end
