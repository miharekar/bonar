require 'open-uri'

desc "This task is called by the Heroku scheduler add-on"

def get_geopedia_coordinates_for address
  p 'Getting Geopedia coords for ' + address
  coordinates = Nokogiri::XML(open(URI.escape('http://services.geopedia.si/geocoding?q=' + address)))
  if(coordinates)
    coordinates = coordinates.xpath("//xmlns:coordinates").first
    if coordinates
      return coordinates.content.split(/,/).reverse
    end
  end
  return nil
end

def get_google_coordinates_for address
  p 'Getting Google coords for ' + address
  coordinates =  Geocoder.coordinates(address + ', Slovenia')
  if(!coordinates)
    p 'Sleeping...'
    sleep(1)
    get_google_coordinates_for address
  end
  return coordinates.map(&:to_s)
end

def get_coordinates_for address
  coordinates = get_geopedia_coordinates_for address
  if !coordinates
    coordinates =  get_google_coordinates_for address
  end
  return coordinates
end

def get_restaurant_id restaurant_div
  link = restaurant_div.css('h1 a').first["href"]
  uri = URI.parse(link)
  parameters = CGI.parse(URI.parse(link).query)
  return parameters['e_restaurant'][0]
end

def create_feature(feature_id, doc)
  title = doc.at_css('#rService' + feature_id).parent['title']
  if title
    @mail_content << 'Creating feature ' + title
    feature = Feature.new
    feature.feature_id = feature_id
    feature.title = doc.at_css('#rService' + feature_id).parent['title']
    return feature
  end
  return nil
end

def get_menu_for restaurant
  doc = Nokogiri::HTML(open(restaurant.link + '0'))
  menu = []
  doc.css('.holderRestaurantInfo>ol>li').each do |li|
    menu_item = []
    li.css('li').each do |course|
      menu_item << course.content.squish
    end
    menu << menu_item
  end
  return menu
end

def get_telephone_for restaurant
  doc = Nokogiri::HTML(open(restaurant.link + '0'))
  tel = doc.at_css('#ContentHolderMain_ContentHolderMainContent_ContentHolderMainContent_lblRestaurantAddress').content
  tel = tel.scan(/tel:(.+)/)
  if tel and tel[0]
    return tel[0][0].gsub(/[^\d,]/,'').gsub(/ +/,'').split(',')
  end
  return nil
end

def get_opening_times_for restaurant
  doc = Nokogiri::HTML(open(restaurant.link + '1'))
  opening_times = {}
  opening_times_ul = doc.at_css('#ContentHolderMain_ContentHolderMainContent_ContentHolderMainContent_riInfo_liWeek').parent.css('li')
  opening_times_ul.each do |li|
    opening_id = li.attribute('id').content.gsub(/ContentHolderMain_ContentHolderMainContent_ContentHolderMainContent_riInfo_li/, '')
    case opening_id
    when 'Week', 'Saturday', 'Sunday'
      if li.content.strip.scan(/\d{2}:\d{2}/).length == 2
        opening_times[opening_id] = li.content.strip.scan(/\d{2}:\d{2}/)
      else
        @mail_content << 'WTF week opening time' + li.content
      end
    when 'Notes'
      opening_times['Notes'] = li.content.gsub('Opombe:', '').squish
    when 'ClosedWeekends'
      opening_times['Saturday'] = false
      opening_times['Sunday'] = false
    when 'ClosedSunday'
      opening_times['Sunday'] = false
    when 'ClosedSaturday'
      opening_times['Saturday'] = false
    else
      @mail_content << 'WTF ID' + opening_id
    end
  end
  return opening_times
end

task update_restaurants: :environment do
  p 'Updating restaurants...'
  @mail_content = ['Restaurant update report']
  doc = Nokogiri::HTML(open('http://www.studentska-prehrana.si/Pages/Directory.aspx'))
  restaurant_items = doc.css('.holderRestaurant ul li ul li:not(.blocked)')
  if restaurant_items.count > 0
    restaurants_to_disable = Restaurant.pluck(:id)
    Restaurant.transaction do
      restaurant_items.each do |div|
        restaurant_id = get_restaurant_id div
        restaurant = Restaurant.find_by_restaurant_id(restaurant_id)
        if restaurant
          restaurants_to_disable.delete(restaurant.id)
        else
          restaurant = Restaurant.new
          restaurant.name = div.css('h1 a').first.content
          restaurant.link = div.css('h1 a').first['href'][0...-1]
          restaurant.restaurant_id = restaurant_id
          restaurant.address = div.css('h2').first.content.gsub(/[()]/, "")
          restaurant.coordinates = get_coordinates_for restaurant.address
          @mail_content << 'Adding new restaurant ' + restaurant.name + ' | ' + restaurant.restaurant_id
        end

        features = []
        div.attribute('sssp:rs').value.split(';').each do |feature_id|
          feature = Feature.find_by_feature_id(feature_id)
          if !feature
            feature = create_feature(feature_id, doc)
          end
          features << feature
        end
        restaurant.features_array = features

        restaurant.price = div.css('.prices strong').first.content
        restaurant.opening = get_opening_times_for restaurant
        restaurant.menu = get_menu_for restaurant
        restaurant.telephone = get_telephone_for restaurant
        restaurant.disabled = false

        p 'Saving ' + restaurant.name + ' - ID: ' + restaurant.restaurant_id
        restaurant.save!
      end
      @mail_content << 'Disabling restaurants: ' + Restaurant.where(id: restaurants_to_disable).pluck(:name).join(', ')
      Restaurant.transaction do
        restaurants_to_disable.each do |id|
          Restaurant.find(id).disable
        end
      end
    end
    @mail_content << 'Total: ' + restaurant_items.count.to_s + ' restaurants.'
  else
    @mail_content << 'Restaurant update failed!'
  end

  if ENV['MAILGUN_API_KEY']
    p 'Sending email...'
    RestClient.post "https://api:#{ENV['MAILGUN_API_KEY']}@api.mailgun.net/v2/app15300758.mailgun.org/messages",
        from: "Boni<info@mr.si>",
        to: "info@mr.si",
        subject: "Restaurants update",
        text: @mail_content.join("\n")
  else
    p @mail_content.join("\n")
  end

  p 'done.'
end