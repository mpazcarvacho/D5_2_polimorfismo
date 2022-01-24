class Cat < ApplicationRecord
  has_many :animals, as: :animalable
end
