class ApiController < ApplicationController
  def restaurants
    @restaurants = Restaurant.active
    if stale?(@restaurants)
      render json: @restaurants, root: false
    end
  end
end
