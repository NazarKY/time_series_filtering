# frozen_string_literal: true

require_relative '../app/parser'

RSpec.describe Parser do
  let(:parser) { Parser.new(filepath: 'spec/data/data.json') }
  let(:daily_dates) { parser.perform.map{ |day| day.first } }

  context 'with default parameters' do
    it 'return array of hashes' do
      expect(parser.perform).to be_a(Array)
      expect(parser.perform.sample).to be_a(Array)
    end

    it 'return only string date and float price' do
      sample = parser.perform.sample
      expect(sample.first).to be_a(String)
      expect(sample.last).to be_a(Float)
    end

    it 'do not return days with no price' do
      expect(parser.perform.map{|day| day.first}.include?(nil)).to be_falsey
    end

    it 'return sorted days' do
      expect(daily_dates).to eq(daily_dates.sort)
    end

    it 'return not duplicated days' do
      expect(daily_dates).to eq(daily_dates.uniq)
    end
  end

  context 'when selected descending sort' do
    it 'return sorted days' do
      parser.order_dir = :desc
      expect(daily_dates).to eq(daily_dates.sort.reverse)
    end
  end

  # context 'when selected not default granularity' do
  #   it 'return sorted days' do
  #     parser.granularity = :weekly
  #     # expect(daily_dates).to eq(daily_dates.sort.reverse)
  #     p parser.perform
  #   end
  # end
end
