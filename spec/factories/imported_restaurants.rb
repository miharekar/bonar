FactoryGirl.define do
  factory :imported_restaurant do
    name 'aga'
    initialize_with { new Nokogiri::XML(File.open("#{Rails.root}/spec/fixtures/restaurants/#{name}.html")).children.first }
  end
end
