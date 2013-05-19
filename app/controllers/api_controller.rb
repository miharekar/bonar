class ApiController < ApplicationController
  def restaurants
    @restaurants = Restaurant.includes(:features).where(disabled: false)
    fresh_when(@restaurants.first)
  end
end
