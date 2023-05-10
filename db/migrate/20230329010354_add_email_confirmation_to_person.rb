class AddEmailConfirmationToPerson < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :confirmed_email, :string
    add_column :people, :confirmation_token, :string
  end
end
