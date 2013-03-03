require 'nokogiri'
require 'open-uri'

class PrehranaController < ApplicationController  
  def get_restaurants_from_web
    restaurants = Array.new 
    doc = Nokogiri::HTML(open('http://www.studentska-prehrana.si/Pages/Directory.aspx'))
    doc.css('.restaurantItem').each do |div|
      restaurant = { 
        :name => div.css('h1 a').first.content,
        :price => div.css('.prices strong').first.content,
        :address => div.css('h2').first.content.gsub(/[()]/, "")
      }
      until restaurant[:coordinates] do
        puts restaurant[:name]
        restaurant[:coordinates] =  Geocoder.coordinates(restaurant[:address] + ', Slovenia')
        if(!restaurant[:coordinates])
          sleep(1)
        end
      end
      restaurants.push restaurant
    end
    
    File.open("restaurants.js", 'w') do |file|
      file.puts restaurants.to_json
    end
  end
  
  def get_restaurants
    if File.exist?("restaurants.js")
      restaurants = JSON.parse open('restaurants.js').read
    else
      get_restaurants
    end 
    
    restaurants
  end
  
  def index
    @restaurants = get_restaurants
  end
end
