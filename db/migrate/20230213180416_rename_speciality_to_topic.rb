class RenameSpecialityToTopic < ActiveRecord::Migration[7.0]
  def change
    rename_table :specialities, :topics
    add_reference :people, :topic, null: true, foreign_key: {to_table: "memberships"}
    remove_reference :people, :speciality
  end
end
