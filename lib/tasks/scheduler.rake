require 'nokogiri'
require 'open-uri'

desc "This task is called by the Heroku scheduler add-on"

def get_coordinate_for_address address
  puts 'getting coords'
  coordinates =  Geocoder.coordinates(address + ', Slovenia')
  if(!coordinates)
    'puts sleeeeeeep'
    sleep(1)
    get_coordinate_for_address address
  else
    coordinates
  end
end

task :loadRestaurants => :environment do
  puts 'Updating restaurants...'
  Restaurant.destroy_all
  doc = Nokogiri::HTML(open('http://www.studentska-prehrana.si/Pages/Directory.aspx'))
  doc.css('.restaurantItem').each do |div|
    restaurant = Restaurant.new
    restaurant.name = div.css('h1 a').first.content
    puts restaurant.name 
    
    restaurant.address = div.css('h2').first.content.gsub(/[()]/, "")
    restaurant.price = div.css('.prices strong').first.content      
    restaurant.coordinates = get_coordinate_for_address restaurant.address
    puts restaurant.coordinates 
      
    restaurant.save
  end
  puts 'done.'
end