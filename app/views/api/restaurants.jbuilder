json.array! @restaurants do |restaurant|
  json.id restaurant.id
  json.name restaurant.name
  json.address restaurant.address
  json.telephone restaurant.telephone
  json.price restaurant.price
  json.coordinates restaurant.coordinates
  json.opening restaurant.opening
  json.menu restaurant.menu
  json.features restaurant.features do |feature|
    json.id feature.feature_id
    json.title feature.title
  end
end