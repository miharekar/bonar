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

def get_content_for restaurant
  content = '<div class="prehrana_info"><h4>' + restaurant.name + '</h4>'
  content += '<address>' + restaurant.address + '</address>'
  content += '<p><strong>' + restaurant.price + '</strong></p>'
  content += '<ul>'
  content += '<li>Delavnik: ' + restaurant.opening['Week'][0] + ' - ' + restaurant.opening['Week'][1] + '</li>'
  if restaurant.opening['Saturday']
    content += '<li>Sobota: ' + restaurant.opening['Saturday'][0] + ' - ' + restaurant.opening['Saturday'][1] + '</li>'
  else
    content += '<li>Sobota: zaprto</li>'
  end
  if restaurant.opening['Sunday']
    content += '<li>Nedelja: ' + restaurant.opening['Sunday'][0] + ' - ' + restaurant.opening['Sunday'][1] + '</li>'
  else
    content += '<li>Nedelja: zaprto</li>'
  end
  if restaurant.opening['Notes']
    content += '<li>Opombe: ' + restaurant.opening['Notes'] + '</li>'
  end
  content += '</ul>'
  content += '<p>Storitve: ' + restaurant.features.map(&:title).join(', ') + '</p>'
  if restaurant.menu.any?
    content += '<p><a href="#" class="loadMenu" data-restaurant="' + restaurant.id.to_s + '">' + 'Jedilnik</a></p>'
  end
  return content
end

task :update_restaurants => :environment do
  p 'Updating restaurants...'
  @mail_content = ['Restaurant update report']
  doc = Nokogiri::HTML(open('http://www.studentska-prehrana.si/Pages/Directory.aspx'))
  restaurant_items = doc.css('.holderRestaurant ul li ul li:not(.blocked)')
  if restaurant_items.count > 0
    restaurants_to_delete = Restaurant.pluck(:id)    
    Restaurant.transaction do
      restaurant_items.each do |div|
        restaurant_id = get_restaurant_id div
        restaurant = Restaurant.find_by_restaurant_id(restaurant_id)        
        if restaurant
          restaurants_to_delete.delete(restaurant.id)
        else
          restaurant = Restaurant.new
          restaurant.name = div.css('h1 a').first.content
          restaurant.link = div.css('h1 a').first['href'][0...-1]
          restaurant.restaurant_id = restaurant_id
          restaurant.address = div.css('h2').first.content.gsub(/[()]/, "")
          restaurant.coordinates = get_coordinates_for restaurant.address
          @mail_content << 'Adding new restaurant ' + restaurant.name + ' | ' + restaurant.restaurant_id
        end
        restaurant.price = div.css('.prices strong').first.content
        
        div.attribute('sssp:rs').value.split(';').each do |feature_id|
          feature = Feature.find_by_feature_id(feature_id)
          if !feature
            feature = create_feature(feature_id, doc)
          end
          restaurant.features << feature
        end
        
        p 'Saving ' + restaurant.name + ' - ID: ' + restaurant.restaurant_id
        restaurant.save!
      end
      @mail_content << 'Deleting restaurants: ' + Restaurant.select(:name).find(restaurants_to_delete).to_s
      Restaurant.delete(restaurants_to_delete)
    end
    @mail_content << 'Total: ' + restaurant_items.count.to_s + ' restaurants.'
    
    p 'Getting opening times, menu and content...'
    Restaurant.all.each do |restaurant|
      restaurant.opening = get_opening_times_for restaurant
      restaurant.menu = get_menu_for restaurant
      restaurant.content = get_content_for restaurant
      
      p 'Saving ' + restaurant.name + ' - ID: ' + restaurant.restaurant_id
      restaurant.save!
    end
  else
    @mail_content << 'Restaurant update failed!'
  end
  
  if ENV['MAILGUN_API_KEY']
    p 'Sending email...'
    API_KEY = ENV['MAILGUN_API_KEY']
    API_URL = "https://api:#{API_KEY}@api.mailgun.net/v2/app12738544.mailgun.org"
    RestClient.post API_URL+"/messages", 
        :from => "Boni<info@mr.si>",
        :to => "info@mr.si",
        :subject => "Restaurants update",
        :text => @mail_content.join("\n") 
  end
  
  p 'done.'
end