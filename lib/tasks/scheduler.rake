require 'nokogiri'
require 'open-uri'

desc "This task is called by the Heroku scheduler add-on"

def get_coordinate_for_address address
  puts 'Getting coords for ' + address
  coordinates =  Geocoder.coordinates(address + ', Slovenia')
  if(!coordinates)
    puts 'Sleeping...'
    sleep(1)
    get_coordinate_for_address address
  else
    coordinates
  end
end

task :loadRestaurants => :environment do
  puts 'Updating restaurants...'
  doc = Nokogiri::HTML(open('http://www.studentska-prehrana.si/Pages/Directory.aspx'))
  restaurantItems = doc.css('.holderRestaurant ul li ul li:not(.blocked)')
  puts restaurantItems.count
  if restaurantItems.count > 0
    Restaurant.transaction do
      Restaurant.destroy_all
      restaurantItems.each do |div|
        restaurant = Restaurant.new
        restaurant.name = div.css('h1 a').first.content
        restaurant.link = div.css('h1 a').first["href"]
        restaurant.address = div.css('h2').first.content.gsub(/[()]/, "")
        restaurant.price = div.css('.prices strong').first.content      
        restaurant.coordinates = get_coordinate_for_address restaurant.address
        puts 'Saving ' + restaurant.name + restaurant.link 
        restaurant.save
      end
    end
  else
    puts 'No restaurants!'
  end
  puts 'done.'
end
