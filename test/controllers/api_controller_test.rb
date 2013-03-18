require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  test "should get restaurants" do
    get :restaurants
    assert_response :success
  end

end
