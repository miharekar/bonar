class ApiController < ApplicationController
  def restaurants
    if params[:search].blank?
      restaurants = Restaurant.all
    else
      restaurants = Restaurant.where('name ILIKE :search OR address ILIKE :search', search: '%' + params[:search] + '%')
    end

    render :json => restaurants.each{|r| r[:link] += '0'}.to_json(only:[:name, :address, :price, :coordinates, :opening, :link, :menu], include:{:features => {:only => [:feature_id, :title]}})
  end
end
