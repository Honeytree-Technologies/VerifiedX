class AddHashtagsToPerson < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :hashtags, :text
    change_column :people, :keywords, :text
  end
end
