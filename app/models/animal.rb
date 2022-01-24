class Animal < ApplicationRecord
  belongs_to :animalable, polymorphic: true
end
