class CreateRestaurants < ActiveRecord::Migration
  def change
    create_table :restaurants do |t|
      t.string :name
      t.string :address
      t.string :price
      t.text :coordinates

      t.timestamps
    end
  end
end
