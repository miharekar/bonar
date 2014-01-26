require 'spec_helper'

describe RestaurantImporter, vcr: { record: :new_episodes } do
  before(:all) do
    VCR.use_cassette('RestaurantImporter/AllRestaurants') { @importer = RestaurantImporter.new }
  end

  let(:aga) { build(:imported_restaurant, name: :aga) }
  let(:celica) { build(:imported_restaurant, name: :celica) }
  let(:feliks) { build(:imported_restaurant, name: :feliks) }

  it 'scrapes multiple restaurants' do
    expect(@importer.restaurants.count).to be > 50
  end

  it 'imports restaurants and disables nonpresent' do
    allow(@importer).to receive(:restaurants).and_return([aga, celica, feliks])
    @importer.import

    expect(Restaurant.find_by(spid: aga.spid)).not_to be_disabled
    expect(Restaurant.find_by(spid: celica.spid)).not_to be_disabled
    expect(Restaurant.find_by(spid: feliks.spid)).not_to be_disabled

    allow(@importer).to receive(:restaurants).and_return([aga, celica])
    @importer.import

    expect(Restaurant.find_by(spid: aga.spid)).not_to be_disabled
    expect(Restaurant.find_by(spid: celica.spid)).not_to be_disabled
    expect(Restaurant.find_by(spid: feliks.spid)).to be_disabled
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
