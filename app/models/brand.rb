# class Brand < ApplicationRecord
#   has_many :cars, dependent: :destroy
# end
class Brand < ApplicationRecord
  has_many :cars,  dependent: :destroy
  validates :name, presence: true
end
