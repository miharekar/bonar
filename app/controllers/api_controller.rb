class ApiController < ApplicationController
  def restaurants
    if stale?(Restaurant.active.first)
      render json: ActiveModel::ArraySerializer.new(Restaurant.active, each_serializer: RestaurantSerializer)
    end
  end
end
