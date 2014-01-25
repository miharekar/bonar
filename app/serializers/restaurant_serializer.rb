class RestaurantSerializer < ActiveModel::Serializer
  attributes :id, :name, :address, :telephones, :price, :latitude, :longitude, :opening, :menu
  has_many :features

  def filter(keys)
    if @scope == :basic
      keys = [:id, :latitude, :longitude, :price]
    else
      keys
    end
  end
end
