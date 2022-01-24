class Duck < ApplicationRecord
  has_many :animals, as: :animalable
end
