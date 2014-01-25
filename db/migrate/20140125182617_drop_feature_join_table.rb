class DropFeatureJoinTable < ActiveRecord::Migration
  def change
    drop_table :features_restaurants
  end
end
