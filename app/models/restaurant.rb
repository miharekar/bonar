class Restaurant < ActiveRecord::Base
  has_and_belongs_to_many :features
  serialize :coordinates, Array
  serialize :menu, Array
  serialize :telephone, Array
  serialize :opening, Hash
  
  def disable
    self.disabled = true
    self.save!
  end
end