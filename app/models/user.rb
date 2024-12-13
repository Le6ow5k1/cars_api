class User < ApplicationRecord
  has_many :user_preferred_brands, dependent: :destroy
  has_many :preferred_brands, through: :user_preferred_brands, source: :brand
  has_many :user_recommended_cars, dependent: :destroy
  has_many :recommended_cars, through: :user_recommended_cars, source: :car
end
