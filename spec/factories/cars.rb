FactoryBot.define do
  factory :car do
    model { 'A7' }
    brand
    price { 40_000 }
  end
end
