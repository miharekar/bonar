class RestaurantSerializer < ActiveModel::Serializer
  attributes :id, :coordinates, :price
end
