class ChangeRestaurantsTelephoneToTelephones < ActiveRecord::Migration
  def change
    rename_column :restaurants, :telephone, :telephones
  end
end
