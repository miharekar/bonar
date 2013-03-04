class AddLinkToRestaurant < ActiveRecord::Migration
  def change
    add_column :restaurants, :link, :string
  end
end
