class Restaurant < ActiveRecord::Base
  serialize :coordinates, Array
end
