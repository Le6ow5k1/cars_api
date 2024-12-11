class Api::CarsController < ApplicationController
  def index
    cars = FindCars.call(**find_cars_params)

    render json: cars
  end

  private

  def find_cars_params
    params.permit(:user_id, :query, :price_min, :price_max, :page).to_h.symbolize_keys
  end
end
