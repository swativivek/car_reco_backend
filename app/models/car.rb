class Car < ApplicationRecord
  belongs_to :brand
  validates :model_name, :price, presence: true
end
