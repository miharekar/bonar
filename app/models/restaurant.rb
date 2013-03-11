class Restaurant < ActiveRecord::Base
  serialize :coordinates, Array
  
  def self.search(search)
    if search.empty?
      all
    else
      where('name ILIKE ? OR address ILIKE ?', "%#{search}%", "%#{search}%")
    end
  end
end