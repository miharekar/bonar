class AddFeaturesArrayToRestaurants < ActiveRecord::Migration
  def change
    add_column :restaurants, :features_array, :integer, array: true, default: []
    add_index :restaurants, :features_array, using: :gin
  end
end
