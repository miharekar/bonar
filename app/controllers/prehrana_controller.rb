class PrehranaController < ApplicationController  
  def index
  end
  
  def search_restaurants
    render :json => Restaurant.search(params[:search]).to_json(only:[:coordinates, :price, :content])
  end
  
  def menu
    if params[:restaurant]
      menu = Restaurant.select(:menu).find(params[:restaurant])
      content = '<ul class="menu">'
      menu[:menu].each do |menu_item|
        content += '<li>' + menu_item.join(', ') + '</li>'
        p menu_item
      end
      content += '</ul>'
      render :text => content
    end
  end
end