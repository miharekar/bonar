require 'nokogiri'
require 'open-uri'

class PrehranaController < ApplicationController
  def get_coordinate_for_address address
    coordinates =  Geocoder.coordinates(address + ', Slovenia')
    if(!coordinates)
      sleep(1)
      get_coordinate_for_address address
    else
      coordinates
    end
  end
  
  def download_and_save_restaurants
    Restaurant.destroy_all
    doc = Nokogiri::HTML(open('http://www.studentska-prehrana.si/Pages/Directory.aspx'))
    doc.css('.restaurantItem').each do |div|
      restaurant = Restaurant.new
      restaurant.name = div.css('h1 a').first.content
      restaurant.address = div.css('h2').first.content.gsub(/[()]/, "")
      restaurant.price = div.css('.prices strong').first.content      
      restaurant.coordinates = get_coordinate_for_address restaurant.address      
      restaurant.save
    end
  end
  
  def get_restaurants
    if (params.include? :recache or Restaurant.count == 0)
      download_and_save_restaurants
      get_restaurants
    else
      Restaurant.all;
    end
  end
  
  def index
    @restaurants = get_restaurants
  end
end
