class AddShowEmailPhoneToPerson < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :show_email, :boolean, default: false
    add_column :people, :show_phone, :boolean, default: false
  end
end
