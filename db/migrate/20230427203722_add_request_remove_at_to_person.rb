class AddRequestRemoveAtToPerson < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :request_remove_at, :datetime
  end
end
