class Restaurant < ActiveRecord::Base
  serialize :menu, Array
  serialize :telephones, Array
  serialize :opening, Hash

  reverse_geocoded_by :latitude, :longitude

  scope :active, -> { where(disabled: false) }
  scope :with_features, -> features { where('features_array @> ARRAY[?]', features.map(&:to_i)) if features.present? }
  scope :with_text, -> text { where('name ILIKE :text OR address ILIKE :text', text: '%' + text + '%') if text.present? }

  def features
    Feature.where(id: features_array).order(:title)
  end

  def disable
    self.disabled = true
    self.save!
  end
end
