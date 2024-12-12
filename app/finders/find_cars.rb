# frozen_string_literal: true

class FindCars
  def self.call(**kwargs)
    new(**kwargs).call
  end

  def initialize(query: nil, price_min: nil, price_max: nil, page: 1)
    @query = query
    @price_min = price_min
    @price_max = price_max
    @page = page
  end

  def call
    cars_scope = Car.includes(:brand).joins(:brand)

    cars_scope = cars_scope.where(price: price_range) if price_range
    cars_scope = cars_scope.where("brands.name ILIKE ?", "%#{query}%") if query.present?

    cars_scope
  end

  private

  attr_reader :query, :price_min, :price_max, :page

  def price_range
    if price_min.present? && price_max.present?
      price_min..price_max
    elsif price_min.present?
      price_min..
    elsif price_max.present?
      ..price_max
    else
      nil
    end
  end
end
