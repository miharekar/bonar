class AddContentToRestaurant < ActiveRecord::Migration
  def change
    add_column :restaurants, :content, :text
  end
end
