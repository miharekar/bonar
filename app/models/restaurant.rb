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
    find_by_sql(['SELECT restaurant_id FROM (
                    SELECT features_restaurants.*, ROW_NUMBER() OVER(PARTITION BY restaurants.id ORDER BY features.id) AS rn FROM restaurants
                    JOIN features_restaurants ON restaurants.id = features_restaurants.restaurant_id
                    JOIN features ON features_restaurants.feature_id = features.id
                    WHERE features.id in (?)
                  ) t
                  WHERE rn = ?', features, features.count])
  end
  
  def self.filter_by_text text
    where('name ILIKE :text OR address ILIKE :text', text: '%' + text + '%')
  end
  
  def self.text_and_features text, features
    text_ids = filter_by_text(text).map(&:id)
    features_ids = filter_by_features(features).map(&:restaurant_id)
    features_ids & text_ids
  end
  
  def self.search text, features
    if !text.blank? and !features.blank?
      text_and_features(text, features)
    elsif !features.blank?
      filter_by_features(features).map(&:restaurant_id)
    else
      filter_by_text(text).map(&:id)
    end
  end
end