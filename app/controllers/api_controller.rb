class ApiController < ApplicationController
  def restaurants
    @restaurants = Restaurant.includes(:features).where(disabled: false)
  end
end
