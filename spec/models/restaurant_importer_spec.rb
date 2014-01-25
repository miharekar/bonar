require 'spec_helper'

describe RestaurantImporter, vcr: { record: :new_episodes } do
  before(:all) do
    VCR.use_cassette('RestaurantImporter/AllRestaurants') { @importer = RestaurantImporter.new }
  end

  it 'scrapes multiple restaurants' do
    expect(@importer.restaurants.count).to be > 50
  end

  context 'single imported restaurant' do
    let(:updated) { @importer.update_restaurant(@importer.restaurants.first) }

    it 'updates Restaurant' do
      expect(updated).to be_true
    end

    it 'doesnt import same restaurant twice' do
      expect(@importer.update_restaurant(@importer.restaurants.first)).to eq(updated)
    end
  end
end
