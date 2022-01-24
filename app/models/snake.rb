class Snake < ApplicationRecord
  has_many :animals, as: :animalable
end
