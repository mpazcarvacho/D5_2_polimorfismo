class Tiger < ApplicationRecord
  has_many :animals, as: :animalable
end
