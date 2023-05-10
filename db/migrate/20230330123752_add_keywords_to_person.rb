class AddKeywordsToPerson < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :keywords, :string
  end
end
