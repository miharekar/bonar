class PrehranaController < ApplicationController
  def index
    redirect_to list_path, notice: 'iOS 7 (še) ne podpira Bonar zemljevida' if is_ios_7?
    @features = Feature.order(:title)
  end

  def all_restaurants
    if stale?(Restaurant.active.first)
      render json: Restaurant.active, root: false, basic: true
    end
  end

  def load_restaurant
    @restaurant = Restaurant.find(params[:restaurant])
    render layout: false
  end
  alias_method :menu, :load_restaurant
  alias_method :content, :load_restaurant

  def search
    restaurants = Restaurant.with_features(params[:features]).with_text(params[:search]).pluck(:id)
    render json: restaurants, root: false
  end

  private
  def is_ios_7?
    user_agent = UserAgent.parse(request.user_agent)
    user_agent.platform == 'iPhone' and user_agent.version.to_s.to_i == 7
  end
end
