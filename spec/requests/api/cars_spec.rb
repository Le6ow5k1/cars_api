require 'rails_helper'

RSpec.describe "Api::Cars", type: :request do
  describe "GET /api/cars" do
    let!(:brand_audi) { create(:brand) }
    let!(:car_audi_a7) { create(:car, brand: brand_audi, model: 'A7') }
    let!(:user) { create(:user, preferred_brands: [brand_audi]) }

    let(:expected_response) do
      [
        {
          "id" => car_audi_a7.id,
          "model" => "A7",
          "price" => 40000,
          "brand" => {
            "id" => brand_audi.id,
            "name" => "Audi"
          },
          "rank_score" => nil,
          "label" => "good_match"
        }
      ]
    end

    it "returns correct response" do
      get "/api/cars", params: {user_id: user.id}

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to match_array(expected_response)
    end
  end
end
