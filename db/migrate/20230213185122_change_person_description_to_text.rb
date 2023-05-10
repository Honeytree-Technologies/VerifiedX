class ChangePersonDescriptionToText < ActiveRecord::Migration[7.0]
  def change
    change_column :people, :description, :text
  end
end
