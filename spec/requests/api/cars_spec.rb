require 'rails_helper'

RSpec.describe "Api::Cars", type: :request do
  describe "GET /api/cars" do
    let!(:brand_audi) { create(:brand) }
    let!(:car_audi_a7) { create(:car, brand: brand_audi, model: 'A7') }
    let!(:user) { create(:user, preferred_brands: [brand_audi]) }

    let(:user_recommended_cars_response) do
      [
        {car_id: car_audi_a7.id, rank_score: 0.945},
      ]
    end

    before do
      allow(UserRecommendedCars).to receive(:call).and_return(user_recommended_cars_response)
    end

    context 'when no parameters are specified' do
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
            "rank_score" => 0.945,
            "label" => "perfect_match"
          }
        ]
      end

      it "returns correct response" do
        get "/api/cars", params: {user_id: user.id}

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to match_array(expected_response)
      end
    end

    context 'when filtered by query' do
      let!(:brand_suzuki) { create(:brand, name: 'Suzuki') }
      let!(:car_suzuki_jimny) { create(:car, brand: brand_suzuki, model: 'Jimny') }

      let(:expected_response) do
        [
          {
            "id" => car_suzuki_jimny.id,
            "model" => "Jimny",
            "price" => 40000,
            "brand" => {
              "id" => brand_suzuki.id,
              "name" => "Suzuki"
            },
            "rank_score" => nil,
            "label" => nil
          }
        ]
      end

      it "returns only cars from brands that match the query" do
        get "/api/cars", params: {user_id: user.id, query: 'Su'}

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to match_array(expected_response)
      end
    end

    context 'when filtered by price range' do
      let!(:brand_suzuki) { create(:brand, name: 'Suzuki') }
      let!(:car_suzuki_jimny) { create(:car, brand: brand_suzuki, model: 'Jimny', price: 29_999) }
      let!(:brand_mercedes) { create(:brand, name: 'Mercedes-Benz') }
      let!(:car_mercedes_jimny) { create(:car, brand: brand_mercedes, model: 'GLA', price: 50_001) }

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
            "rank_score" => 0.945,
            "label" => "perfect_match"
          }
        ]
      end

      it "returns only cars from brands that match the query" do
        get "/api/cars", params: {user_id: user.id, price_min: 30_000, price_max: 50_000}

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to match_array(expected_response)
      end
    end

    context 'when page parameter is provided' do
      let!(:brand_suzuki) { create(:brand, name: 'Suzuki') }
      let!(:suzuki_cars) { create_list(:car, 20, brand: brand_suzuki, model: 'Jimny', price: 29_999) }

      let(:expected_response) do
        [
          {
            "id" => suzuki_cars.last.id,
            "model" => suzuki_cars.last.model,
            "price" => 29_999,
            "brand" => {
              "id" => brand_suzuki.id,
              "name" => "Suzuki",
            },
            "rank_score" => nil,
            "label" => nil,
          }
        ]
      end

      it "returns only cars from brands that match the query" do
        get "/api/cars", params: {user_id: user.id, page: 2}

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to match_array(expected_response)
      end
    end

    context 'when page parameter is provided' do
      let!(:brand_suzuki) { create(:brand, name: 'Suzuki') }
      let!(:suzuki_cars) { create_list(:car, 20, brand: brand_suzuki, model: 'Jimny', price: 29_999) }

      let(:expected_response) do
        [
          {
            "id" => suzuki_cars.last.id,
            "model" => suzuki_cars.last.model,
            "price" => 29_999,
            "brand" => {
              "id" => brand_suzuki.id,
              "name" => "Suzuki",
            },
            "rank_score" => nil,
            "label" => nil,
          }
        ]
      end

      it "returns only cars from brands that match the query" do
        get "/api/cars", params: {user_id: user.id, page: 2}

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to match_array(expected_response)
      end
    end

    context 'when there are cars with different label, rank score and price' do
      let!(:brand_suzuki) { create(:brand, name: 'Suzuki') }
      let!(:car_suzuki_jimny) { create(:car, brand: brand_suzuki, model: 'Jimny', price: 39_999) }
      let!(:car_suzuki_vitara) { create(:car, brand: brand_suzuki, model: 'Vitara', price: 50_999) }
      let!(:brand_bmw) { create(:brand, name: 'BMW') }
      let!(:car_bmw_x6) { create(:car, brand: brand_bmw, model: 'X6', price: 79_999) }
      let!(:user) { create(:user, preferred_brands: [brand_audi, brand_suzuki, brand_bmw]) }

      let(:user_recommended_cars_response) do
        [
          {car_id: car_audi_a7.id, rank_score: 0.945},
          {car_id: car_suzuki_jimny.id, rank_score: 0.8},
          {car_id: car_suzuki_vitara.id, rank_score: 0.8},
          {car_id: car_bmw_x6.id, rank_score: 0.8},
        ]
      end

      let(:expected_response) do
        [
          {
            "id" => car_audi_a7.id,
            "model" => car_audi_a7.model,
            "price" => 40_000,
            "brand" => {
              "id" => brand_audi.id,
              "name" => "Audi",
            },
            "rank_score" => 0.945,
            "label" => "perfect_match",
          },
          {
            "id" => car_suzuki_jimny.id,
            "model" => car_suzuki_jimny.model,
            "price" => 39_999,
            "brand" => {
              "id" => brand_suzuki.id,
              "name" => "Suzuki",
            },
            "rank_score" => 0.8,
            "label" => "perfect_match",
          },
          {
            "id" => car_suzuki_vitara.id,
            "model" => car_suzuki_vitara.model,
            "price" => 50_999,
            "brand" => {
              "id" => brand_suzuki.id,
              "name" => "Suzuki",
            },
            "rank_score" => 0.8,
            "label" => "good_match",
          },
          {
            "id" => car_bmw_x6.id,
            "model" => car_bmw_x6.model,
            "price" => 79_999,
            "brand" => {
              "id" => brand_bmw.id,
              "name" => "BMW",
            },
            "rank_score" => 0.8,
            "label" => "good_match",
          }
        ]
      end

      it "returns only cars from brands that match the query" do
        get "/api/cars", params: {user_id: user.id}

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to match_array(expected_response)
      end
    end
  end
end
