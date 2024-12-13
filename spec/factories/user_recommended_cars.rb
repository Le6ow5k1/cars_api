FactoryBot.define do
  factory :user_recommended_car do
    user
    car
    rank_score { 0.5 }
  end
end
