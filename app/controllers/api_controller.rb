class ApiController < ApplicationController
  def restaurants
    if params[:search].blank?
      restaurants = Restaurant.all
    else
      restaurants = Restaurant.where('name ILIKE :search OR address ILIKE :search', search: '%' + params[:search] + '%')
    end
    render :json => restaurants.to_json(only:[:id, :name, :address, :price, :coordinates, :opening])
  end

  def menu
    if !params[:restaurant].blank?
      render :json => Restaurant.select(:menu).find(params[:restaurant])[:menu]
    end
  end

  def features
    if !params[:restaurant].blank?
      render :json => Restaurant.find(params[:restaurant]).features
    end
  end
end
