class User < ApplicationRecord
  has_many :user_preferred_brands
  has_many :preferred_brands, through: :user_preferred_brands, source: :brand
  validates :email, :preferred_price_range, presence: true
end
