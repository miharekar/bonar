class ListController < ApplicationController
  def index
  end

  def nearest
    Restaurant.nearest_to_position params[:coords]
    raise a
    render json: params.to_json
  end
end
