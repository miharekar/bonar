task update_restaurants: :environment do
  p 'Updating restaurants...'
  p RestaurantImporter.new.import
  p 'done.'
end
