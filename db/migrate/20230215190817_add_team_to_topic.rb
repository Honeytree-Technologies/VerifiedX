class AddTeamToTopic < ActiveRecord::Migration[7.0]
  def change
    add_reference :topics, :team, null: false, foreign_key: true
  end
end
