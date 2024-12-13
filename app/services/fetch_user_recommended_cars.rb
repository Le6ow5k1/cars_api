# frozen_string_literal: true

require 'net/http'

class FetchUserRecommendedCars
  BASE_URL = 'https://bravado-images-production.s3.amazonaws.com/recomended_cars.json'

  def self.call(**kwargs)
    new(**kwargs).call
  end

  def initialize(user_id:)
    @user_id = user_id
  end

  def call
    response = Net::HTTP.get_response(url)

    case response
    when Net::HTTPSuccess
      JSON.parse(response.body, symbolize_names: true)
    else
      []
    end
  rescue JSON::ParserError
    []
  end

  private

  attr_reader :user_id

  def url
    return @url if @url

    @url = URI.parse(BASE_URL)
    @url.query = URI.encode_www_form(user_id: user_id)
    @url
  end
end
