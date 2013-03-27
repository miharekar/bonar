class Restaurant < ActiveRecord::Base
  has_and_belongs_to_many :features
  serialize :coordinates, Array
  serialize :menu, Array
  serialize :opening, Hash
end