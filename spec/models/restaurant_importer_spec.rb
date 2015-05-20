require 'rails_helper'

describe RestaurantImporter, vcr: { record: :new_episodes } do
  before(:all) do
    VCR.use_cassette('RestaurantImporter/AllRestaurants') { @importer = RestaurantImporter.new }
  end

  let(:aga) { build(:imported_restaurant, name: :aga) }
  let(:aga_new_address) { build(:imported_restaurant, name: :aga_new_address) }
  let(:celica) { build(:imported_restaurant, name: :celica) }
  let(:feliks) { build(:imported_restaurant, name: :feliks) }
  let(:slovenj_gradec) { build(:imported_restaurant, name: :slovenj_gradec) }
  let(:aga_spid) { '8T8W26CAVLRWKC6TPZ7CDL5RHS' }
  let(:celica_spid) { 'D5HE9HE54UGNKDTALN9C8PQ722' }
  let(:feliks_spid) { 'SCPQ5CPX7CRRXX8G8AZVGB5VEA' }

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
      expect(updated).to be_truthy
    end

    it 'doesnt import same restaurant twice' do
      expect(@importer.update_restaurant(@importer.restaurants.first)).to eq(updated)
    end

    it 'doesnt overwrite coordinates' do
      allow(@importer).to receive(:restaurants).and_return([aga])
      @importer.import
      Restaurant.find_by(spid: aga_spid).update(latitude: '46.1234', longitude: '15.1234')
      @importer.import

      expect(Restaurant.find_by(spid: aga_spid).latitude).to eq(46.1234)
      expect(Restaurant.find_by(spid: aga_spid).longitude).to eq(15.1234)
    end
  end

  context 'reporting' do
    it 'reports new restaurants' do
      allow(@importer).to receive(:restaurants).and_return([aga])
      @importer.import
      expect(@importer.report).to include({ new: [aga_spid] })

      allow(@importer).to receive(:restaurants).and_return([aga, celica, feliks])
      @importer.import
      expect(@importer.report).to include({ new: [celica_spid, feliks_spid] })
    end

    it 'reports disabled restaurants' do
      allow(@importer).to receive(:restaurants).and_return([aga, celica, feliks])
      @importer.import

      allow(@importer).to receive(:restaurants).and_return([aga, celica])
      @importer.import

      expect(@importer.report).to include({ disabled: [feliks_spid] })
    end

    it 'reports changed address' do
      allow(@importer).to receive(:restaurants).and_return([aga])
      @importer.import
      allow(@importer).to receive(:restaurants).and_return([aga_new_address])
      @importer.import
      expect(@importer.report).to include({ faulty: [{
        spid: "8T8W26CAVLRWKC6TPZ7CDL5RHS",
        old_address: "Čopova ulica 12, Ljubljana",
        new_address: "Špikova ulica 12, Ljubljana"}
      ]})
    end

    it 'reports errors as faulty updates' do
      allow(@importer).to receive(:restaurants).and_return([slovenj_gradec])
      @importer.import
      expect(@importer.report).to include({ faulty: [{spid:'HRH7AHUGJKNT32BL83UK5M47CA', error: "undefined method `content' for nil:NilClass"}] })
    end

    it 'reports new features' do
      allow(@importer).to receive(:restaurants).and_return([aga])
      @importer.import
      features = Restaurant.find_by(spid: aga_spid).features.pluck(:spid)
      expect(@importer.report).to include({ new_features: features })
    end

    it 'returns report after import' do
      allow(@importer).to receive(:restaurants).and_return([aga, celica, feliks])
      expect(@importer.import).to include({ new: [aga_spid, celica_spid, feliks_spid] })
    end
  end
end
