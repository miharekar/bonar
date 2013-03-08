class PrehranaController < ApplicationController  
  def index
  end
  
  def search_restaurants
    if params[:search]
      if params[:search].empty?
        render json: Restaurant.all.as_json(only:[:name, :address, :coordinates, :link, :price])
      else
        render json: Restaurant.all(:conditions => ['lower(name) like ? OR lower(address) like ? ', "%#{params[:search].downcase}%", "%#{params[:search].downcase}%"]).as_json(only:[:name, :address, :coordinates, :link, :price])
      end
    end
  end
end