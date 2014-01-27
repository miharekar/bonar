task update_restaurants: :environment do
  ri = RestaurantImporter.new
  ri.import
  mail = Updates.restaurant(ri.report)
  mail.deliver if mail.body.parts.present?
end
