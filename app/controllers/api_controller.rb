class ApiController < ApplicationController
  def restaurants
    @restaurants = Restaurant.includes(:features)
    if params[:search].blank?
      @restaurants = @restaurants.where(disabled: false)
    else
      @restaurants = @restaurants.where(disabled: false).where('name ILIKE :search OR address ILIKE :search', search: '%' + params[:search] + '%')
    end
  end
end
