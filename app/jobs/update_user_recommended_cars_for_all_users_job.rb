class UpdateUserRecommendedCarsForAllUsersJob < ApplicationJob
  queue_as :default

  def perform
    User.select(:id).find_each do |user|
      UpdateUserRecommendedCarsJob.perform_now(user.id)
    end
  end
end
