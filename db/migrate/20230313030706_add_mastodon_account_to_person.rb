class AddMastodonAccountToPerson < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :mastodon_account, :jsonb
  end
end
