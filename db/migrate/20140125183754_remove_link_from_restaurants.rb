class RemoveLinkFromRestaurants < ActiveRecord::Migration
  def change
    remove_column :restaurants, :link, :string
  end
end
