require 'spec_helper'

describe ImportedRestaurant, vcr: { record: :new_episodes } do
  let(:aperitivo) { build(:imported_restaurant, name: :aperitivo) }
  let(:celica) { build(:imported_restaurant, name: :celica) }
  let(:aga) { build(:imported_restaurant, name: :aga) }
  let(:feliks) { build(:imported_restaurant, name: :feliks) }
  let(:katra) { build(:imported_restaurant, name: :katra) }
  let(:klementina) { build(:imported_restaurant, name: :klementina) }
  let(:damajanty) { build(:imported_restaurant, name: :damajanty) }

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
    expect(aperitivo.price).to eq('1,87 EUR')
    expect(celica.price).to eq('3,15 EUR')
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

  it 'gets opening times' do
    expect(aperitivo.opening[:week]).to match_array(['08:00', '20:00'])
    expect(aperitivo.opening[:saturday]).to match_array(['08:00', '14:00'])
    expect(aperitivo.opening[:sunday]).to be_false

    expect(celica.opening[:week]).to match_array(['11:00', '16:00'])
    expect(celica.opening[:saturday]).to be_false
    expect(celica.opening[:sunday]).to be_false

    expect(klementina.opening[:week]).to match_array(['12:00', '20:00'])
    expect(klementina.opening[:saturday]).to match_array(['12:00', '20:00'])
    expect(klementina.opening[:sunday]).to match_array(['12:00', '20:00'])
    expect(klementina.opening[:notes]).to eq('Ponedeljek in torek ZAPRTO')

    expect(damajanty.opening[:saturday]).to be_false
  end
end
