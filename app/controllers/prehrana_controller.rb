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
    if !params[:features].blank? and !params[:search].blank?
      restaurant_ids = Restaurant.search_and_features(params[:search], params[:features])
    elsif !params[:features].blank?
      restaurant_ids = Restaurant.filter_by_features(params[:features]).map(&:restaurant_id)
    else
      restaurant_ids = Restaurant.search(params[:search]).map(&:id)
    end

    render json: restaurant_ids
  end
end