# frozen_string_literal: true

class FindUserCars
  DEFAULT_PER_PAGE = 20

  def self.call(**kwargs)
    new(**kwargs).call
  end

  def initialize(user_id:, query: nil, price_min: nil, price_max: nil, page: 1)
    @user_id = user_id
    @query = query
    @price_min = price_min && Float(price_min)
    @price_max = price_max && Float(price_max)
    @page = page
  end

  def call
    cars = Car.connection.select_all(
      Car.sanitize_sql_array(
        [
          sql_query(query: query),
          preferred_brand_ids: user_preferred_brand_ids,
          pref_price_min: user.preferred_price_range.first,
          pref_price_max: user.preferred_price_range.last,
          query: query && "%#{Car.sanitize_sql_like(query)}%",
          price_min: price_min,
          price_max: price_max,
          limit: DEFAULT_PER_PAGE,
          offset: offset
        ]
      )
    )

    cars.map do |car|
      {
        id: car['id'],
        brand: {
          id: car['brand_id'],
          name: car['brand_name'],
        },
        model: car['model'],
        price: car['price'],
        rank_score: car['rank_score'] && Float(car['rank_score']),
        label: car['label'],
      }
    end
  end

  private

  attr_reader :user_id, :query, :price_min, :price_max, :page

  def sql_query(query: nil)
    <<~SQL
      WITH filtered_cars AS (
        SELECT
          CASE WHEN brand_id = ANY(ARRAY[:preferred_brand_ids]) AND price BETWEEN :pref_price_min AND :pref_price_max THEN 'perfect_match'
               WHEN brand_id = ANY(ARRAY[:preferred_brand_ids]) THEN 'good_match'
               ELSE NULL
          END AS label,
          user_recommended_cars.rank_score,
          cars.id,
          cars.price,
          cars.model,
          brands.id as brand_id,
          brands.name as brand_name
        FROM
          "cars"
          INNER JOIN "brands" ON "brands"."id" = "cars"."brand_id"
          LEFT OUTER JOIN "user_recommended_cars" ON "user_recommended_cars"."car_id" = "cars"."id"
        WHERE
          1 = 1
          #{'AND cars.price >= :price_min' if price_min}
          #{'AND cars.price <= :price_max' if price_max}
          #{"AND brands.name ILIKE :query" if query.present?}
      )
      SELECT
        *
      FROM
        filtered_cars
      ORDER BY
        CASE WHEN label = 'perfect_match' THEN 0 WHEN label = 'good_match' THEN 1 ELSE 2 END,
        rank_score DESC NULLS LAST,
        price
      LIMIT
        :limit OFFSET :offset;
    SQL
  end

  def user_preferred_brand_ids
    @user_preferred_brand_ids ||= user.preferred_brand_ids
  end

  def user
    @user ||= User.includes(:preferred_brands).find(user_id)
  end

  def user_recommended_cars
    @user_recommended_cars ||= FetchUserRecommendedCars.call(user_id: user_id).index_by { |r| r[:car_id] }
  end

  def offset
    (Integer(page) - 1) * DEFAULT_PER_PAGE
  end
end
