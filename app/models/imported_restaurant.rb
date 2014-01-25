class ImportedRestaurant
  RESTAURANT_URL = 'http://www.studentska-prehrana.si/Pages/RestaurantInfo.aspx?e_restaurant=%s&feature=%d'

  def initialize(html)
    @html = html
  end

  def menu_html
    @menu_html ||= Nokogiri::HTML(open(RESTAURANT_URL % [spid, 0]))
  end

  def info_html
    @info_html ||= Nokogiri::HTML(open(RESTAURANT_URL % [spid, 1]))
  end

  def spid
    url = @html.at_css('h1 a')['href']
    Rack::Utils.parse_query(URI(url).query)['e_restaurant']
  end

  def name
    @html.at_css('h1 a').content.gsub(/\"/, '')
  end

  def address
    @html.at_css('h2').content.gsub(/[()]/, '')
  end

  def price
    @html.at_css('.prices strong').content.gsub(',', '.').to_f
  end

  def spfeatures
    @html.attribute('sssp:rs').value.split(';').map(&:to_i)
  end

  def latitude
    coordinates[:latitude]
  end

  def longitude
    coordinates[:longitude]
  end

  def telephones
    parse_telephone menu_html.at_css('h2 span').content.match(/tel:(.*)\)/)
  end

  def menu
    menu_html.css('.holderRestaurantInfo>ol>li').inject([]) do |m, o|
      m << parse_offer(o)
    end
  end

  private
  def parse_telephone(match)
    return [] unless match
    match.captures.first.split(',').each_with_object([]) do |tel, o|
      o.concat tel.gsub(/\D/, '').scan(/.{1,9}/)
    end
  end

  def parse_offer(offer)
    offer.css('li').inject([]) do |i, course|
      i << course.content.squish
    end
  end

  def coordinates
    @coordinates ||= get_geopedia_coordinates || get_google_coordinates || { latitude: 0, longitude: 0 }
  end

  def get_geopedia_coordinates
    response = Nokogiri::XML(open(URI.escape("http://services.geopedia.si/geocoding?q=#{address}")))
    c = response.try(:xpath, "//xmlns:coordinates").try(:first).try(:content).try(:split, /,/)
    { latitude: c[1].to_f, longitude: c[0].to_f } if c
  end

  def get_google_coordinates
    c = Geocoder.coordinates(address + ', Slovenia')
    { latitude: c[0].to_f, longitude: c[1].to_f } if c
  end

end
