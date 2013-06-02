class PrehranaController < ApplicationController
  def index
    @features = Feature.all
  end

  def all_restaurants
    @restaurants = Restaurant.where(disabled: false)
    fresh_when(@restaurants.first)
  end
  
  def menu
    @restaurant = Restaurant.find(params[:restaurant])
    render layout: false
  end
  
  def content
    @restaurant = Restaurant.find(params[:restaurant])
    render layout: false
  end

  def search
    render json: Restaurant.search(params[:search], params[:features])
  end
end