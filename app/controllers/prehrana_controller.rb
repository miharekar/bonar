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
    features_ids = Restaurant.filter_by_features(params[:features]).map(&:restaurant_id) unless params[:features].blank?
    search_ids = Restaurant.search(params[:search]).map(&:id) unless params[:search].blank?
    
    if !params[:features].blank? and !params[:search].blank?
      restaurant_ids = features_ids & search_ids
    else
      restaurant_ids = search_ids || features_ids
    end

    render json: restaurant_ids
  end
end