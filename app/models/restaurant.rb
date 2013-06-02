class Restaurant < ActiveRecord::Base
  has_and_belongs_to_many :features
  serialize :coordinates, Array
  serialize :menu, Array
  serialize :telephone, Array
  serialize :opening, Hash
  
  def disable
    self.disabled = true
    self.save!
  end
  
  def self.filter_by_features features
    Restaurant.find_by_sql(['SELECT restaurant_id FROM (
                               SELECT features_restaurants.*, ROW_NUMBER() OVER(PARTITION BY restaurants.id ORDER BY features.id) AS rn FROM restaurants
                               JOIN features_restaurants ON restaurants.id = features_restaurants.restaurant_id
                               JOIN features ON features_restaurants.feature_id = features.id
                               WHERE features.id in (?)
                             ) t
                             WHERE rn = ?', features, features.count]).map(&:restaurant_id)
  end
end