class PrehranaController < ApplicationController  
  def index
  end
  
  def search_restaurants
    render :json => Restaurant.search(params[:search]).to_json(only:[:coordinates, :price, :content])
  end
end