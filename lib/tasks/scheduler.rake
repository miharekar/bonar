require 'open-uri'

desc "This task is called by the Heroku scheduler add-on"

def get_geopedia_coordinates_for address
  puts 'Getting Geopedia coords for ' + address
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
  puts 'Getting Google coords for ' + address
  coordinates =  Geocoder.coordinates(address + ', Slovenia')
  if(!coordinates)
    puts 'Sleeping...'
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
  parameters['e_restaurant'][0]  
end

task :load_restaurants => :environment do
  puts 'Updating restaurants...'
  mail_content = ['Restaurant update report']
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
          restaurant.link = div.css('h1 a').first["href"][0...-1]
          restaurant.restaurant_id = restaurant_id
          restaurant.address = div.css('h2').first.content.gsub(/[()]/, "")
          restaurant.price = div.css('.prices strong').first.content      
          restaurant.coordinates = get_coordinates_for restaurant.address
          mail_content << 'Adding new restaurant ' + restaurant.name + ' | ' + restaurant.restaurant_id
          restaurant.save!
        end
      end
      mail_content << 'Deleting restaurants: ' + Restaurant.select(:name).find(restaurants_to_delete).to_s
      Restaurant.delete(restaurants_to_delete)
    end
    mail_content << 'Total: ' + restaurant_items.count.to_s + ' restaurants.'
  else
    mail_content << 'Restaurant update failed!'
  end
  
  puts 'sending email'
  API_KEY = ENV['MAILGUN_API_KEY']
  API_URL = "https://api:#{API_KEY}@api.mailgun.net/v2/app12738544.mailgun.org"
  RestClient.post API_URL+"/messages", 
      :from => "Boni<info@mr.si>",
      :to => "info@mr.si",
      :subject => "Restaurants update",
      :text => mail_content.join("\n") 
      
  puts 'done.'
end

task :get_opening_times => :environment do
  puts 'Getting opening times...'
  
  Restaurant.all.each do |restaurant|
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
          puts li.content #this need to be mailed!
        end
      when 'Notes'
        opening_times['Notes'] = li.content.gsub('Opombe:', '').strip.squish
      when 'ClosedWeekends'
        opening_times['Saturday'] = false
        opening_times['Sunday'] = false
      when 'ClosedSunday'
        opening_times['Sunday'] = false
      when 'ClosedSaturday'
        opening_times['Saturday'] = false
      else
        puts opening_id #this need to be mailed!
      end
      
    end
    restaurant.opening = opening_times
    restaurant.save
  end

  puts 'done.'
end