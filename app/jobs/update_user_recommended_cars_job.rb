class UpdateUserRecommendedCarsJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    User.find(user_id)
    recommended_cars = FetchUserRecommendedCars.call(user_id: user_id)
    return if recommended_cars.empty?

    records_to_upsert = recommended_cars.map do |car_recommendation|
      {
        user_id: user_id,
        car_id: car_recommendation[:car_id],
        rank_score: car_recommendation[:rank_score],
        created_at: Time.current,
        updated_at: Time.current
      }
    end
    UserRecommendedCar.upsert_all(records_to_upsert, unique_by: :uniq_user_recommended_cars)
  end
end
