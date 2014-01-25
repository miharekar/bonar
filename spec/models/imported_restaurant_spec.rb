require 'spec_helper'

describe ImportedRestaurant do
  let(:aperitivo) { ImportedRestaurant.new Nokogiri::XML(File.open("#{Rails.root}/spec/fixtures/restaurants/aperitivo.html", "r:UTF-8"), nil, 'UTF-8').children.first }
  let(:celica) { ImportedRestaurant.new Nokogiri::XML(File.open("#{Rails.root}/spec/fixtures/restaurants/celica.html", "r:UTF-8"), nil, 'UTF-8').children.first }

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

  it 'gets coordinates(latitude and longitude)', :vcr do
    expect(celica.latitude).to be_within(0.0005).of(46.0566030)
    expect(celica.longitude).to be_within(0.0005).of(14.5165372)
    expect(aperitivo.latitude).to be_within(0.0005).of(46.0564509)
    expect(aperitivo.longitude).to be_within(0.0005).of(14.5080702)
  end

  it 'gets telephones'
  it 'gets menu'
  it 'gets opening times'
end
