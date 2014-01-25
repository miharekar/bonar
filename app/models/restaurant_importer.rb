class RestaurantImporter
  DIRECTORY_URL = 'http://www.studentska-prehrana.si/Pages/Directory.aspx'

  def initialize
    @doc = Nokogiri::HTML(open(DIRECTORY_URL))
  end

  def restaurants
    @restaurants ||= @doc.css('.holderRestaurant ul li ul li:not(.blocked)')
  end

  def import
    restaurants.each do |restaurant|
      update_restaurant restaurant
    end
  end

  def update_restaurant(restaurant)
    ir = ImportedRestaurant.new(restaurant)
    r = Restaurant.find_or_create_by(spid: ir.spid).update(
      spid: ir.spid,
      name: ir.name,
      address: ir.address,
      price: ir.price,
      features_array: build_features_array(ir),
      latitude: ir.latitude,
      longitude: ir.longitude,
      telephones: ir.telephones,
      menu: ir.menu,
      opening: ir.opening
    )
  end

  private
  def build_features_array(ir)
    ir.spfeatures.inject([]) do |fa, spid|
      fa << get_feature(spid).id
    end
  end

  def get_feature(spid)
    Feature.find_or_create_by(spid: spid) do |f|
      f.title = @doc.at_css("#rService#{spid}").parent['title']
    end
  end
end
