class PrehranaController < ApplicationController  
  def index
  end
  
  def all_restaurants
    render :json => Restaurant.all.to_json(only:[:id, :coordinates, :price], methods:[:content, :feature_ids])
  end
  
  def menu
    if params[:restaurant]
      menu = Restaurant.select(:menu).find(params[:restaurant])[:menu]
      content = '<ol class="menu">'
      menu.each do |menu_item|
        content += '<li>' + menu_item.join(', ') + '</li>'
      end
      content += '</ol>'
      render :text => content
    end
  end
end