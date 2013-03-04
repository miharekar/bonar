class PrehranaController < ApplicationController  
  def index
    @restaurants = Restaurant.all
  end
  
  def search_restaurants
    if params[:search]
      render :json => Restaurant.find(:all, :conditions => ['name LIKE ?', "%#{params[:search]}%"])
    end
  end
end
