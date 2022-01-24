class Dog < ApplicationRecord
  has_many :animals, as: :animalable
end
