class Feature < ActiveRecord::Base
  def restaurants
    Restaurant.where('features_array @> ARRAY[?]', id)
  end
end
