class AddOpeningToRestaurant < ActiveRecord::Migration
  def change
    add_column :restaurants, :opening, :text
  end
end
