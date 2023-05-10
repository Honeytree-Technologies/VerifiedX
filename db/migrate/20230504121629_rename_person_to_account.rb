class RenamePersonToAccount < ActiveRecord::Migration[7.0]
  def change
    rename_table :people, :accounts
    rename_table :people_topics, :accounts_topics
    rename_column :accounts_topics, :person_id, :account_id
  end
end
