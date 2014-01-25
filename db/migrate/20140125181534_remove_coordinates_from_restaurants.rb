class RemoveCoordinatesFromRestaurants < ActiveRecord::Migration
  def change
    remove_column :restaurants, :coordinates, :text
  end
end
