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
          restaurant.coordinates = get_coordinate_for_address restaurant.address
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
