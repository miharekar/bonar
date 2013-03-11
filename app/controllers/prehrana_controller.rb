class PrehranaController < ApplicationController  
  def index
  end
  
  def search_restaurants
    render json: Restaurant.search(params[:search]).as_json(only:[:name, :address, :coordinates, :link, :price])
  end
end