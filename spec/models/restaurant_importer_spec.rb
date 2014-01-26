require 'spec_helper'

describe RestaurantImporter, vcr: { record: :new_episodes } do
  before(:all) do
    VCR.use_cassette('RestaurantImporter/AllRestaurants') { @importer = RestaurantImporter.new }
  end

  let(:aga) { build(:imported_restaurant, name: :aga) }
  let(:celica) { build(:imported_restaurant, name: :celica) }
  let(:feliks) { build(:imported_restaurant, name: :feliks) }
  let(:r_aga) { Restaurant.find_by(spid: '8T8W26CAVLRWKC6TPZ7CDL5RHS') }
  let(:r_celica) { Restaurant.find_by(spid: 'D5HE9HE54UGNKDTALN9C8PQ722') }
  let(:r_feliks) { Restaurant.find_by(spid: 'SCPQ5CPX7CRRXX8G8AZVGB5VEA') }

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

  context 'reports' do
    it 'new restaurants' do
      allow(@importer).to receive(:restaurants).and_return([aga])
      @importer.import
      expect(@importer.report).to include({ new: [r_aga] })

      allow(@importer).to receive(:restaurants).and_return([aga, celica, feliks])
      @importer.import
      expect(@importer.report).to include({ new: [r_celica, r_feliks] })
    end

    it 'disabled restaurants' do
      allow(@importer).to receive(:restaurants).and_return([aga, celica, feliks])
      @importer.import

      allow(@importer).to receive(:restaurants).and_return([aga, celica])
      @importer.import

      expect(@importer.report).to include({ disabled: [r_feliks] })
    end
  end
end
