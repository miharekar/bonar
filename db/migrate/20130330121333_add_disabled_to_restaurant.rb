class AddDisabledToRestaurant < ActiveRecord::Migration
  def change
    add_column :restaurants, :disabled, :boolean, default: false
  end
end
