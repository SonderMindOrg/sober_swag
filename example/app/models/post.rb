##
# Extremely basic post example record.
# This is a blog post! Wow.
class Post < ApplicationRecord
  belongs_to :person

  validates :title, presence: true
  validates :body, presence: true
end
