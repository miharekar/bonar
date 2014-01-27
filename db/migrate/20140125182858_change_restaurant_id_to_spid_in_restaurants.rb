class ChangeRestaurantIdToSpidInRestaurants < ActiveRecord::Migration
  def change
    rename_column :restaurants, :restaurant_id, :spid
    add_index :restaurants, :spid
  end
end
