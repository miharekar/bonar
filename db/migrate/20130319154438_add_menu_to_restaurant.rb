class AddMenuToRestaurant < ActiveRecord::Migration
  def change
    add_column :restaurants, :menu, :text
  end
end
