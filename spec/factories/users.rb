FactoryBot.define do
  factory :user do
    email { 'example@mail.com' }
    preferred_price_range { 30_000...40_000 }
    association :preferred_brands, factory: :brand
  end
end
