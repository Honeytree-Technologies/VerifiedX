class AddInstanceToPerson < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :instance, :string
  end
end
