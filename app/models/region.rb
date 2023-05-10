class Region < ApplicationRecord
  belongs_to :country
  has_many :accounts

  validates :name, presence: true, uniqueness: { scope: :country_id }
end
