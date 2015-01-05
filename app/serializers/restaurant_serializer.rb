class RestaurantSerializer < ActiveModel::Serializer
  attributes :id, :name, :address, :telephone, :price, :latitude, :longitude, :opening, :menu
  has_many :features

  self.root = false

  def filter(keys)
    if scope == :basic
      keys = [:id, :latitude, :longitude, :price]
    else
      keys - [:latitude, :longitude] + [:coordinates]
    end
  end

  def telephone
    object.telephones
  end

  def coordinates
    [object.latitude, object.longitude]
  end
end
