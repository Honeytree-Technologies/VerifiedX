class Membership < ApplicationRecord
  include Memberships::Base
  # 🚅 add concerns above.

  # 🚅 add belongs_to associations above.

  # 🚅 add has_many associations above.

  # 🚅 add oauth providers above.

  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  # 🚅 add validations above.
  validate :validates_default_team

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  # 🚅 add methods above.


  private
  def validates_default_team
    if user && (user.memberships.count > 1 || user.memberships.first&.id != self.id)
      errors.add(:base, "User already has a team")
    end
  end
end
