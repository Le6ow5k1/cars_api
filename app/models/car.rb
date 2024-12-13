class Car < ApplicationRecord
  belongs_to :brand
  has_many :user_recommended_cars, dependent: :destroy
end
