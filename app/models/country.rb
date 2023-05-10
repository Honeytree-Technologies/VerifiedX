class Country < ApplicationRecord
  has_many :regions

  validates :name, uniqueness: true, presence: true
end
