class PrehranaController < ApplicationController  
  def index
    @restaurants = Restaurant.all
  end
  
  def search_restaurants
    if params[:search]
      render :json => Restaurant.find(:all, :conditions => ['lower(name) like ? OR lower(address) like ? ', "%#{params[:search].downcase}%", "%#{params[:search].downcase}%"])
    else
      render :json => Restaurant.all
    end
  end
end
