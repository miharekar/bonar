class PrehranaController < ApplicationController
  def index
    if is_ios_7?
      redirect_to :list_index, notice: 'iOS 7 (še) ne podpira Bonar zemljevida'
    end

    @features = Feature.all.order(:title)
  end

  def all_restaurants
    @restaurants = Restaurant.where(disabled: false)
    fresh_when(@restaurants.first)
  end

  def menu
    @restaurant = Restaurant.find(params[:restaurant])
    render layout: false
  end

  def content
    @restaurant = Restaurant.find(params[:restaurant])
    render layout: false
  end

  def search
    render json: Restaurant.filter_by_features(params[:features]).filter_by_text(params[:search]).map(&:id)
  end

  private
  def is_ios_7?
    user_agent = UserAgent.parse(request.user_agent)
    user_agent.platform == 'iPhone' and user_agent.version.to_s.to_i == 7
  end
end