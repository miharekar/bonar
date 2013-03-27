json.cache! @restaurants.first do
  json.array! @restaurants do |restaurant|
    json.id restaurant.id
    json.coordinates restaurant.coordinates
    json.price restaurant.price
  end
end