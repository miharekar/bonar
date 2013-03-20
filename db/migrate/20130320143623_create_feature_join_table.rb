class CreateFeatureJoinTable < ActiveRecord::Migration
  def change
    create_join_table :features, :restaurants do |t|
      # t.index [:feature_id, :restaurant_id]
      t.index [:restaurant_id, :feature_id], unique: true
    end
  end
end
