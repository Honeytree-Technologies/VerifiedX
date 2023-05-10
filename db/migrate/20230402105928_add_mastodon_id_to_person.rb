class AddMastodonIdToPerson < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :mastodon_id, :string
  end
end
