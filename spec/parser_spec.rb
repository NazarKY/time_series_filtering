# frozen_string_literal: true

require_relative '../app/parser'

RSpec.describe Parser do
  let(:parser) { Parser.new(filepath: 'spec/data/data.json') }

  context 'with default parameters' do
    it 'return array of hashes' do
      expect(parser.perform).to be_a(Array)
      expect(parser.perform.sample).to be_a(Hash)
    end

    it 'return only date and price' do
      expect(parser.perform.sample.keys).to eq([:date, :price])
    end

    it 'do not return days with no price' do
      expect(parser.perform.map{|day| day[:date]}.include?(nil)).to be_falsey
    end

    it 'do not return duplication days and sorted' do
      parse_result = parser.perform.map{ |day| day[:date] }
      expect(parse_result.uniq).to eq(parse_result.sort)
    end
  end
end
