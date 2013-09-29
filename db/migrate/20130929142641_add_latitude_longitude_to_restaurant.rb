class AddLatitudeLongitudeToRestaurant < ActiveRecord::Migration
  def change
    add_column :restaurants, :latitude, :decimal
    add_column :restaurants, :longitude, :decimal

    add_index :restaurants, [:latitude, :longitude]
  end
end
