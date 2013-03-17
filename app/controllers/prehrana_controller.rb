class PrehranaController < ApplicationController  
  def index
  end
  
  def get_content_for restaurant
    content = '<div class="prehrana_info"><h4><a href="' + restaurant['link'] + '0" target="_blank">' + restaurant['name'] + '</a></h4>'
    content += '<address>' + restaurant['address'] + '</address>'
    content += '<p><strong>' + restaurant['price'] + '</strong></p>'
    content += '<ul>'
    content += '<li>Teden: ' + restaurant['opening']['Week'][0] + ' - ' + restaurant['opening']['Week'][1] + '</li>'
    if restaurant['opening']['Saturday']
      content += '<li>Sobota: ' + restaurant['opening']['Saturday'][0] + ' - ' + restaurant['opening']['Saturday'][1] + '</li>'
    else
      content += '<li>Sobota: zaprto</li>'
    end
    if restaurant['opening']['Sunday']
      content += '<li>Nedelja: ' + restaurant['opening']['Sunday'][0] + ' - ' + restaurant['opening']['Sunday'][1] + '</li>'
    else
      content += '<li>Nedelja: zaprto</li>'
    end
    if restaurant['opening']['Notes']
      content += '<li>Opombe: ' + restaurant['opening']['Notes'] + '</li>'
    end
    content += '</ul></div>'
  end
  
  def search_restaurants
    restaurants = Restaurant.search(params[:search])
    json = []
    restaurants.each do |restaurant|
      r = {}
      r['price'] = restaurant.price[0]
      r['coordinates'] = restaurant.coordinates
      r['content'] = get_content_for restaurant
      json << r
    end
    
    render :json => json.to_json
  end
end