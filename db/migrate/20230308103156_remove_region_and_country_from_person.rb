class RemoveRegionAndCountryFromPerson < ActiveRecord::Migration[7.0]
  def change
    remove_column :people, :country
    remove_column :people, :region
  end
end
