class AddTelephoneToRestaurant < ActiveRecord::Migration
  def change
    add_column :restaurants, :telephone, :text
  end
end
