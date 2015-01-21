class PrehranaController < ApplicationController
  def index
    @features = Feature.order(:title)
  end

  def all_restaurants
    if stale?(Restaurant.active.first)
      render json: Restaurant.active, scope: :basic, root: false
    end
  end

  def load_restaurant
    @restaurant = Restaurant.find(params[:restaurant])
    render layout: false
  end
  alias_method :menu, :load_restaurant
  alias_method :content, :load_restaurant

  def search
    ids = Restaurant.with_features(params[:features]).with_text(params[:search]).pluck(:id)
    render json: ids, root: false
  end
end
