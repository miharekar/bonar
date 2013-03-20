class Restaurant < ActiveRecord::Base
  has_and_belongs_to_many :features
  serialize :coordinates, Array
  serialize :menu, Array
  serialize :opening, Hash
  
  def self.search(search)
    if search.empty?
      all
    else
      where('name ILIKE :search OR address ILIKE :search', search: '%' + search + '%')
    end
  end
end