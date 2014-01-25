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
      parse_restaurant restaurant
    end
  end

  def parse_restaurant(restaurant)
    ir = ImportedRestaurant.new(restaurant)
    Restaurant.find_or_create_by(restaurant_id: ir.spid) do |r|
      r.restaurant_id = ir.spid
      r.name = ir.name
      r.address = ir.address
      r.price = ir.price
      r.features_array = build_features_array(ir)
      r.latitude = ir.latitude
      r.longitude = ir.longitude
    end
  end

  private
  def build_features_array(ir)
    ir.spfeatures.inject([]) do |fa, spid|
      fa << get_feature(spid).id
    end
  end

  def get_feature(spid)
    Feature.find_or_create_by(feature_id: spid) do |f|
      f.title = @doc.at_css("#rService#{spid}").parent['title']
    end
  end
end
