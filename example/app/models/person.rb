##
# Extremely basic person example record.
class Person < ApplicationRecord
  has_many :posts, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
end
