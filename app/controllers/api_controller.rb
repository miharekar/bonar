class ApiController < ApplicationController
  def restaurants
    if params[:search]
      restaurants = Restaurant.search(params[:search])
    else
      restaurants = Restaurant.all
    end
    
    render :json => restaurants.each{|r| r[:link] += '0'}.to_json(only:[:name, :address, :price, :coordinates, :opening, :link, :menu])
  end
end
