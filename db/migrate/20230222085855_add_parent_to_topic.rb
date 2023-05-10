class AddParentToTopic < ActiveRecord::Migration[7.0]
  def change
    add_column :topics, :parent_id, :integer
  end
end
