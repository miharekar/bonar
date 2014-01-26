task update_restaurants: :environment do
  ri = RestaurantImporter
  ri.import
  Updates.restaurant(ri.report).deliver
end
