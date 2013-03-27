json.array! @restaurants do |restaurant|
  json.id restaurant.id
  json.name restaurant.name
  json.address restaurant.address
  json.telephone restaurant.telephone
  json.price restaurant.price
  json.coordinates restaurant.coordinates
  json.opening restaurant.opening
end