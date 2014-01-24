require 'spec_helper'

describe RestaurantImporter do
  let(:ri) { RestaurantImporter.new }
  it 'imports restaurants' do
    expect(ri.import).to be_true
  end
end
