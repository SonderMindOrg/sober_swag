class Person < ApplicationRecord
  has_many :posts, dependent: :destroy
end
