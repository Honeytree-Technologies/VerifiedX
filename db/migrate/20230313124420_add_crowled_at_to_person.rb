class AddCrowledAtToPerson < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :crowled_at, :datetime
  end
end
