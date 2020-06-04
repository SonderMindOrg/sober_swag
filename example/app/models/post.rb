class Post < ApplicationRecord
  belongs_to :person

  validates :title, presence: true
  validates :body, presence: true
end
