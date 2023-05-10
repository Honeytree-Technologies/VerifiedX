class AddAccountTypeToPeople < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :account_type, :integer, default: 0
  end
end
