class PrehranaController < ApplicationController  
  def index
    @restaurants = Restaurant.all
  end
end
