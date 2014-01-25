require 'spec_helper'

describe RestaurantImporter, vcr: { record: :new_episodes } do
  before(:all) do
    VCR.use_cassette('RestaurantImporter/AllRestaurants') { @importer = RestaurantImporter.new }
  end

  it 'scrapes multiple restaurants' do
    expect(@importer.restaurants.count).to be > 100
  end

  context 'single imported restaurant' do
    let(:parsed) { @importer.parse_restaurant(@importer.restaurants.first) }
    it 'parses it to Restaurant' do
      expect(parsed).to be_instance_of(Restaurant)
      expect(parsed.name).to eq('Aperitivo Ljubljana')
      expect(parsed.restaurant_id).to eq('CRK3PKZVD5HW2N2TPB8JZUE7RA')
      expect(parsed.address).to eq('Ambrožev trg 10, Ljubljana')
      expect(parsed.price).to eq(1.87)
      expect(parsed.features.length).to eq(3)
      expect(parsed.latitude).to be_within(0.0005).of(46.0564509)
      expect(parsed.longitude).to be_within(0.0005).of(14.5080702)
      expect(parsed.telephone).to eq([])
      expect(parsed.menu.length).to eq(3)
    end

    it 'doesnt import same restaurant twice' do
      expect(@importer.parse_restaurant(@importer.restaurants.first)).to eq(parsed)
    end
  end
end
