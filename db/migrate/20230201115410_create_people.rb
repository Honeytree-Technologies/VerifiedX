class CreatePeople < ActiveRecord::Migration[7.0]
  def change
    create_table :people do |t|
      t.references :team, null: false, foreign_key: true
      t.string :name
      t.string :mastodon_handle
      t.string :twitter_handle
      t.string :area_of_focus
      t.string :where_to_publish
      t.string :description

      t.timestamps
    end
  end
end
