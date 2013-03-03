class Restaurant < ActiveRecord::Base
  attr_accessible :address, :coordinates, :name, :price
  serialize :coordinates, Array
end
