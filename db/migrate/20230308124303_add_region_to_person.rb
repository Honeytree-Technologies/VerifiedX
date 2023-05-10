class AddRegionToPerson < ActiveRecord::Migration[7.0]
  def change
    add_reference :people, :region, foreign_key: true
  end
end
