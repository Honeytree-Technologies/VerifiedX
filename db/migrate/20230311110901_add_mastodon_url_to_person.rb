class AddMastodonUrlToPerson < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :mastodon_url, :string
  end
end
