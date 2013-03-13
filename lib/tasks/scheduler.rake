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

task :load_restaurants => :environment do
  puts 'Updating restaurants...'
  doc = Nokogiri::HTML(open('http://www.studentska-prehrana.si/Pages/Directory.aspx'))
  restaurant_items = doc.css('.holderRestaurant ul li ul li:not(.blocked)')
  if restaurant_items.count > 0
    Restaurant.transaction do
      Restaurant.delete_all
      restaurant_items.each do |div|
        restaurant = Restaurant.new
        restaurant.name = div.css('h1 a').first.content
        restaurant.link = div.css('h1 a').first["href"][0...-1]
        restaurant.address = div.css('h2').first.content.gsub(/[()]/, "")
        restaurant.price = div.css('.prices strong').first.content      
        restaurant.coordinates = get_coordinate_for_address restaurant.address
        puts 'Saving ' + restaurant.name
        restaurant.save!
      end
    end
    mail_content = 'Updated ' + restaurant_items.count.to_s + ' restaurants.'
  else
    mail_content = 'Restaurant update failed!'
  end
  puts mail_content
  
  puts 'sending email'
  API_KEY = ENV['MAILGUN_API_KEY']
  API_URL = "https://api:#{API_KEY}@api.mailgun.net/v2/app12738544.mailgun.org"
  RestClient.post API_URL+"/messages", 
      :from => "Boni<info@mr.si>",
      :to => "info@mr.si",
      :subject => "Restaurants update",
      :text => mail_content
      
  puts 'done.'
end
