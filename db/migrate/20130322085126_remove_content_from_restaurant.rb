class RemoveContentFromRestaurant < ActiveRecord::Migration
  def change
    remove_column :restaurants, :content, :text
  end
end
