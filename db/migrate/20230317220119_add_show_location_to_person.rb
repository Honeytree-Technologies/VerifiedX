class AddShowLocationToPerson < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :show_location, :boolean, default: true
  end
end
