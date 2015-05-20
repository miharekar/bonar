class RestaurantImporter
  DIRECTORY_URL = 'https://www.studentska-prehrana.si/Pages/Directory.aspx'
  attr_reader :report

  def initialize
    @doc = Nokogiri::HTML(open(DIRECTORY_URL))
  end

  def restaurants
    @restaurants ||= build_restaurants
  end

  def import
    @report = Hash.new{ |h,k| h[k] = [] }
    restaurants.each { |r| update_restaurant(r) }
    disable_nonpresent_restaurants
    @report
  end

  def update_restaurant(ir)
    restaurant = get_restaurant(ir)
    restaurant.update!(
      name: ir.name,
      price: ir.price,
      features_array: build_features_array(ir),
      telephones: ir.telephones,
      menu: ir.menu,
      opening: ir.opening,
      disabled: false
    )
    if restaurant.address != ir.address
      @report[:faulty] << {
        spid: ir.spid,
        old_address: restaurant.address,
        new_address: ir.address
      }
    end
  rescue => e
    @report[:faulty] << { spid: ir.spid, error: e.message }
  end

  private
  def get_restaurant ir
    Restaurant.find_or_create_by(spid: ir.spid) do |r|
      @report[:new] << ir.spid
      r.address = ir.address
      r.latitude = ir.latitude
      r.longitude = ir.longitude
    end
  end

  def disable_nonpresent_restaurants
    spids = restaurants.map(&:spid)
    to_disable = Restaurant.active.where.not(spid: spids)
    @report[:disabled] = to_disable.pluck(:spid)
    to_disable.update_all(disabled: true)
  end

  def build_restaurants
    restaurants = @doc.css('.holderRestaurant ul li ul li:not(.blocked)')
    restaurants.map{ |r| ImportedRestaurant.new(r) }
  end

  def build_features_array(ir)
    ir.spfeatures.inject([]) do |fa, spid|
      fa << get_feature(spid).id
    end
  end

  def get_feature(spid)
    Feature.find_or_create_by(spid: spid) do |f|
      f.title = @doc.at_css("#rService#{spid}").parent['title']
      @report[:new_features] << spid
    end
  end
end
