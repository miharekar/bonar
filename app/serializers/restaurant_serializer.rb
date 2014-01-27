class RestaurantSerializer < ActiveModel::Serializer
  attributes :id, :name, :address, :telephone, :price, :coordinates, :opening, :menu
  has_many :features

  def filter(keys)
    if @scope == :basic
      keys = [:id, :latitude, :longitude, :price]
    else
      keys
    end
  end

  def telephone
    object.telephones
  end

  def coordinates
    [object.latitude, object.longitude]
  end
end
