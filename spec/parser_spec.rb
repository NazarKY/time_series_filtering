# frozen_string_literal: true

require_relative '../app/parser'

RSpec.describe Parser do
  let(:parser) { Parser.new(filepath: 'spec/data/data.json') }

  context 'with default parameters' do
    let(:days_dates) { parser.perform.map{ |day| day[:date] } }

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

    it 'return sorted days' do
      expect(days_dates).to eq(days_dates.sort)
    end

    it 'return not duplicated days' do
      expect(days_dates).to eq(days_dates.uniq)
    end
  end
end
