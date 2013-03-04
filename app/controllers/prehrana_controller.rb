class PrehranaController < ApplicationController  
  def index
    @restaurants = Restaurant.all
  end
  
  def search_restaurants
    if params[:search]
      render :json => Restaurant.find(:all, :conditions => ['lower(name) like ?', "%#{params[:search].downcase}%"])
    end
  end
end
