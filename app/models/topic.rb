class Topic < ApplicationRecord

  belongs_to :team
  has_and_belongs_to_many :accounts
  belongs_to :parent, class_name: 'Topic', foreign_key: :parent_id, optional: true
  has_many :children, class_name: 'Topic', foreign_key: :parent_id



  validates :name, presence: true, uniqueness: true


  def all_children
    return [] if children.count.zero?

    children.map { |topic| topic.all_children + [topic] }.flatten
  end

  def breadcrumb
    (parent.nil? ? [] : parent.breadcrumb) + [name]
  end
end
