class ImportedRestaurant
  def initialize(html)
    @html = html
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

  private
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
