class ApiController < ApplicationController
  def restaurants
    if stale?(Restaurant.active.first)
      render json: Restaurant.active, root: false
    end
  end
end
