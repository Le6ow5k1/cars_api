# frozen_string_literal: true

class UserCars
  DEFAULT_PER_PAGE = 20

  def self.call(**kwargs)
    new(**kwargs).call
  end

  def initialize(user_id:, query: nil, price_min: nil, price_max: nil, page: 1)
    @user_id = user_id
    @query = query
    @price_min = price_min
    @price_max = price_max
    @page = page
  end

  def call
    cars_scope = FindCars.call(query: query, price_min: price_min, price_max: price_max, page: page)

    serialized_cars = cars_scope.map do |car|
      serialize_car(car: car, rank_score: rank_score(car), label: recommendation_label(car))
    end

    serialized_cars.sort_by!(&method(:sort_cars_by))

    serialized_cars[offset..(offset + DEFAULT_PER_PAGE)]
  end

  private

  attr_reader :user_id, :query, :price_min, :price_max, :page

  def offset
    (Integer(page) - 1) * DEFAULT_PER_PAGE
  end

  def rank_score(car)
    user_recommended_cars.fetch(car.id, {})[:rank_score]
  end

  def recommendation_label(car)
    preferred_brand = user.preferred_brands.include?(car.brand)
    preferred_price = user.preferred_price_range.include?(car.price)

    if preferred_brand && preferred_price
      :perfect_match
    elsif preferred_brand
      :good_match
    end
  end

  def user
    @user ||= User.includes(:preferred_brands).find(user_id)
  end

  def user_recommended_cars
    @user_recommended_cars ||= UserRecommendedCars.call(user_id: user_id).index_by { |r| r[:car_id] }
  end

  def serialize_car(car:, rank_score: nil, label:)
    car_attributes = car.as_json(only: [:id, :model, :price], include: {brand: {only: [:id, :name]}})
    car_attributes['rank_score'] = rank_score
    car_attributes['label'] = label

    car_attributes
  end

  def sort_cars_by(car)
    [
      recommendation_label_priority(car['label']),
      car['rank_score'] ? -car['rank_score'] : Float::INFINITY,
      car['price']
    ]
  end

  def recommendation_label_priority(label)
    case label
    when :perfect_match then 0
    when :good_match then 1
    else
      2
    end
  end
end