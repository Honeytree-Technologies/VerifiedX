class CreatePersonTopics < ActiveRecord::Migration[7.0]
  def change
    create_table :people_topics do |t|
      t.references :person, null: false, foreign_key: true
      t.references :topic, null: false, foreign_key: true

      t.timestamps
    end
  end
end
