class AddActiveToPerson < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :active, :boolean, default: false
  end
end
