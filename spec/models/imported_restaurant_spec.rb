require 'spec_helper'

describe ImportedRestaurant, vcr: { record: :new_episodes } do
  def imported_restaurant_for(name)
    ImportedRestaurant.new Nokogiri::XML(File.open("#{Rails.root}/spec/fixtures/restaurants/#{name}.html", "r:UTF-8"), nil, 'UTF-8').children.first
  end

  let(:aperitivo) { imported_restaurant_for('aperitivo') }
  let(:celica) { imported_restaurant_for('celica') }
  let(:aga) { imported_restaurant_for('aga') }
  let(:feliks) { imported_restaurant_for('feliks') }
  let(:katra) { imported_restaurant_for('katra') }

  it 'parses Studentska Prehrana ID - spid' do
    expect(aperitivo.spid).to eq('CRK3PKZVD5HW2N2TPB8JZUE7RA')
    expect(celica.spid).to eq('D5HE9HE54UGNKDTALN9C8PQ722')
  end

  it 'parses name' do
    expect(aperitivo.name).to eq('Aperitivo Ljubljana')
    expect(celica.name).to eq('Celica hostel')
  end

  it 'parses address' do
    expect(aperitivo.address).to eq('Ambrožev trg 10, Ljubljana')
    expect(celica.address).to eq('Metelkova 8, Ljubljana')
  end

  it 'parses price' do
    expect(aperitivo.price).to eq(1.87)
    expect(celica.price).to eq(3.15)
  end

  it 'parses Studentska Prehrana Features - spfeatures' do
    expect(aperitivo.spfeatures).to match_array([2, 10, 11])
    expect(celica.spfeatures).to match_array([2, 7, 8, 11])
  end

  it 'gets coordinates(latitude and longitude)' do
    expect(celica.latitude).to be_within(0.0005).of(46.0566030)
    expect(celica.longitude).to be_within(0.0005).of(14.5165372)
    expect(aperitivo.latitude).to be_within(0.0005).of(46.0564509)
    expect(aperitivo.longitude).to be_within(0.0005).of(14.5080702)
  end

  it 'gets telephones' do
    expect(aperitivo.telephones).to eq([])
    expect(celica.telephones).to eq([])
    expect(aga.telephones).to match_array(['014302105'])
    expect(feliks.telephones).to match_array(['045151520', '051320520'])
    expect(katra.telephones).to match_array(['015427000', '015427105', '041722272', '041722027'])
  end

  it 'gets menu' do
    expect(aperitivo.menu).to match_array([
      ['gobova/goveja', 'solata s slanino', 'sezonsko sadje'],
      ['gobova/goveja', 'vegi sendvič', 'sezonsko sadje'],
      ['paradižnikova', 'sirni krožnik', 'sezonsko sadje']
    ])
    expect(celica.menu).to eq([])
  end

  it 'gets opening times'
end
