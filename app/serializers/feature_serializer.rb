class FeatureSerializer < ActiveModel::Serializer
  attributes :id, :title

  def id
    object.spid
  end
end
