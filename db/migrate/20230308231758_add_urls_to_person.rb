class AddUrlsToPerson < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :urls, :jsonb, default: []
  end
end
