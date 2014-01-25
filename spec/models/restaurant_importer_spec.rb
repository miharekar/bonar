require 'spec_helper'

describe RestaurantImporter, :vcr do
  before(:all) do
    VCR.use_cassette('RestaurantImporter/AllRestaurants') { @ri = RestaurantImporter.new }
  end

  it 'scrapes multiple restaurants' do
    expect(@ri.restaurants.count).to be > 100
  end

  context 'single imported restaurant' do
    it 'parses it to Restaurant' do
      r = @ri.parse_restaurant(@ri.restaurants.first)

      expect(r).to be_instance_of(Restaurant)
      expect(r.name).to eq('Aperitivo Ljubljana')
      expect(r.restaurant_id).to eq('CRK3PKZVD5HW2N2TPB8JZUE7RA')
      expect(r.address).to eq('Ambrožev trg 10, Ljubljana')
      expect(r.price).to eq(1.87)
      expect(r.features.length).to eq(3)
      expect(r.latitude).to be_within(0.0005).of(46.0564509)
      expect(r.longitude).to be_within(0.0005).of(14.5080702)
    end
  end
end
