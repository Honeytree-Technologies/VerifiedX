class AddAddressToPeople < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :address, :text
  end
end
