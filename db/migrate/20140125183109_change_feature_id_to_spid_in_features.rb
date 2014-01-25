class ChangeFeatureIdToSpidInFeatures < ActiveRecord::Migration
  def change
    rename_column :features, :feature_id, :spid
    add_index :features, :spid
  end
end
