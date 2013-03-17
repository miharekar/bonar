class PrehranaController < ApplicationController  
  def index
  end
  
  def search_restaurants
    @restaurants = Restaurant.search(params[:search])
    render :json => @restaurants.to_json
  end
end