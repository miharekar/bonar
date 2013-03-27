class PrehranaController < ApplicationController
  def index
    @features = Feature.all
  end

  def all_restaurants
    @restaurants = Restaurant.all
  end
  
  def menu
    @restaurant = Restaurant.find(params[:restaurant])
    render :layout => false
  end
  
  def content
    @restaurant = Restaurant.find(params[:restaurant])
    render :layout => false
  end

  def search
    if !params[:features].blank?
      restaurant_ids = Restaurant.find_by_sql(['SELECT restaurant_id FROM (
                                                  SELECT features_restaurants.*, ROW_NUMBER() OVER(PARTITION BY restaurants.id ORDER BY features.id) AS rn FROM restaurants
                                                  JOIN features_restaurants ON restaurants.id = features_restaurants.restaurant_id
                                                  JOIN features ON features_restaurants.feature_id = features.id
                                                  WHERE features.id in (?)
                                                ) t
                                                WHERE rn = ?', params[:features], params[:features].count]).map(&:restaurant_id)
    end

    if !params[:search].blank?
      if restaurant_ids
        restaurants = Restaurant.where('(name ILIKE :search OR address ILIKE :search) AND id IN (:ids)', search: '%' + params[:search] + '%', ids: restaurant_ids)
      else
        restaurants = Restaurant.where('name ILIKE :search OR address ILIKE :search', search: '%' + params[:search] + '%')
      end
      restaurant_ids = restaurants.map(&:id)
    end

    render :json => restaurant_ids
  end
end