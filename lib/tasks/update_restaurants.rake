task update_restaurants: :environment do
  ri = RestaurantImporter.new
  ri.import
  Updates.restaurant(ri.report).deliver
end
