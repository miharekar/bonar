class PrehranaController < ApplicationController  
  def index
  end
  
  def search_restaurants
    if params[:search]
      render :json => Restaurant.find(:all, :conditions => ['lower(name) like ? OR lower(address) like ? ', "%#{params[:search].downcase}%", "%#{params[:search].downcase}%"])
    end
  end
end