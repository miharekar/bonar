class FeatureSerializer < ActiveModel::Serializer
  attributes :id, :title

  def id
    object.feature_id
  end
end
