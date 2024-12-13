class CreateUserRecommendedCars < ActiveRecord::Migration[6.1]
  def change
    create_table :user_recommended_cars do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.references :car, null: false, foreign_key: true, index: false
      t.decimal :rank_score, precision: 5, scale: 4

      t.index [:user_id, :car_id], unique: true, name: :uniq_user_recommended_cars

      t.timestamps
    end
  end
end
