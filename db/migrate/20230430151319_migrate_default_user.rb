class MigrateDefaultUser < ActiveRecord::Migration[7.0]
  def change
    if User.count.zero?
      user = User.create(
        email: 'admin@verifiedx.org',
        first_name: 'Admin',
        last_name: 'VerifiedX',
        time_zone: Rails.application.config.time_zone,
        password: 'verifiedx'
      )
      team = Team.create(name: 'Default', time_zone: Rails.application.config.time_zone)
      Membership.reset_column_information
      team.memberships.create(user: user, roles: [Role.admin])
      user.update(current_team_id: team.id, last_seen_at: DateTime.now)
    end
  end
end
