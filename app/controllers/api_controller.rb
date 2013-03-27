class ApiController < ApplicationController
  def restaurants
    @restaurants = Restaurant.includes(:features)
    if params[:search].blank?
      @restaurants = @restaurants.all
    else
      @restaurants = @restaurants.where('name ILIKE :search OR address ILIKE :search', search: '%' + params[:search] + '%')
    end
  end
end
