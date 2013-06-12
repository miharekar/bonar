class ApiController < ApplicationController
  def restaurants
    @restaurants = Restaurant.where(disabled: false)
    fresh_when(@restaurants.first)
  end
end
