class Restaurant < ActiveRecord::Base
  serialize :coordinates, Array
  
  def self.search(search)
    if search.empty?
      all
    else
      where('name ILIKE :search OR address ILIKE :search', search: '%' + search + '%')
    end
  end
end