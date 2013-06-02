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
    restaurant_ids = Restaurant.filter_by_features params[:features] unless params[:features].blank?
    
    if !params[:search].blank?
      if restaurant_ids
        restaurants = Restaurant.where('(name ILIKE :search OR address ILIKE :search) AND id IN (:ids)', search: '%' + params[:search] + '%', ids: restaurant_ids)
      else
        restaurants = Restaurant.where('name ILIKE :search OR address ILIKE :search', search: '%' + params[:search] + '%')
      end
      restaurant_ids = restaurants.map(&:id)
    end

    render json: restaurant_ids
  end
end