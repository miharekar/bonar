require 'spec_helper'

describe Updates do
  describe 'restaurant' do
    context 'empty report' do
      let(:mail) { Updates.restaurant({}) }

      it 'renders the subject' do
        expect(mail.subject).to eq('Bonar restaurants updated')
      end

      it 'Miha is the receiver' do
        expect(mail.to).to eq(['info@mr.si'])
      end

      it 'boni is the sender' do
        expect(mail.from).to eq(['info@mr.si'])
      end

      it 'has no body' do
        expect(mail.body.parts.length).to eq(0)
      end
    end

    context 'full report', vcr: { record: :new_episodes } do
      let(:aga) { build(:imported_restaurant, name: :aga) }
      let(:celica) { build(:imported_restaurant, name: :celica) }
      let(:slovenj_gradec) { build(:imported_restaurant, name: :slovenj_gradec) }

      before(:all) {
        VCR.use_cassette('RestaurantImporter/AllRestaurants') { @importer = RestaurantImporter.new }
      }

      it 'generates a multipart message (plain text and html)' do
        allow(@importer).to receive(:restaurants).and_return([aga])
        @importer.import
        mail = Updates.restaurant(@importer.report)
        expect(mail.body.parts.length).to eq(2)
        expect(mail.body.parts.collect(&:content_type)).to match_array(["text/html; charset=UTF-8", "text/plain; charset=UTF-8"])
      end

      it 'includes faulty updates in body' do
        allow(@importer).to receive(:restaurants).and_return([aga, slovenj_gradec])
        @importer.import
        mail = Updates.restaurant(@importer.report)
        content = mail.body.parts.find{|p| p.content_type.match /plain/}.body.raw_source
        expect(content).to include('Faulty updates')
        expect(content).to include('HRH7AHUGJKNT32BL83UK5M47CA')
      end

      it 'includes new restaurants in body' do
        allow(@importer).to receive(:restaurants).and_return([aga])
        @importer.import
        mail = Updates.restaurant(@importer.report)
        content = mail.body.parts.find{|p| p.content_type.match /plain/}.body.raw_source

        expect(content).to include('New restaurants')
        expect(content).to include('Aga')
        expect(content).to include('8T8W26CAVLRWKC6TPZ7CDL5RHS')
      end

      it 'includes disabled restaurants in body' do
        allow(@importer).to receive(:restaurants).and_return([aga, celica])
        @importer.import
        allow(@importer).to receive(:restaurants).and_return([aga])
        @importer.import

        mail = Updates.restaurant(@importer.report)
        content = mail.body.parts.find{|p| p.content_type.match /plain/}.body.raw_source

        expect(content).to include('Disabled restaurants')
        expect(content).to include('Celica')
        expect(content).to include('D5HE9HE54UGNKDTALN9C8PQ722')
      end

      it 'includes new features in body' do
        allow(@importer).to receive(:restaurants).and_return([aga])
        @importer.import
        mail = Updates.restaurant(@importer.report)
        content = mail.body.parts.find{|p| p.content_type.match /plain/}.body.raw_source

        expect(content).to include('New features')
        expect(content).to include('hitra hrana - 13')
      end
    end
  end
end
