class AddSpecialityToPeople < ActiveRecord::Migration[7.0]
  def change
    add_reference :people, :speciality, null: true, foreign_key: {to_table: "memberships"}
  end
end
