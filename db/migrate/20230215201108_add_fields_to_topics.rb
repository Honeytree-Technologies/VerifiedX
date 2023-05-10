class AddFieldsToTopics < ActiveRecord::Migration[7.0]
  def change
    add_column :topics, :definition, :text
    add_column :topics, :qcode, :string
    add_column :topics, :wikidata, :string
    add_column :topics, :uri, :string
  end
end
