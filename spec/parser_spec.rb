# frozen_string_literal: true

require_relative '../app/parser'

shared_examples 'correct formatter' do
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

  it 'return not duplicated days' do
    expect(daily_dates).to eq(daily_dates.uniq)
  end
end

RSpec.describe Parser do
  let(:parser) { Parser.new(filepath: 'spec/data/data.json') }
  let(:daily_dates) { parser.perform.map{ |day| day.first } }

  context 'with default parameters' do
    it_behaves_like 'correct formatter'

    it 'return reversely sorted days' do
      expect(daily_dates).to eq(daily_dates.sort.reverse)
    end
  end

  context 'when selected ascending sort' do
    before do
      parser.order_dir = :asc
    end

    it_behaves_like 'correct formatter'

    it 'return sorted days' do
      expect(daily_dates).to eq(daily_dates.sort)
    end
  end

  context 'when selected weekly granularity' do
    before do
      parser.granularity = :weekly
    end

    it_behaves_like 'correct formatter'

    it 'return correct date range' do
      expect(parser.perform.first).to eq(['2018-11-22', 4890.46])
      expect(parser.perform.last).to eq(['2013-07-06', 79.45])
    end
  end

  context 'when selected monthly granularity' do
    before do
      parser.granularity = :monthly
    end

    it_behaves_like 'correct formatter'

    it 'return correct date range' do
      expect(parser.perform.first).to eq(['2018-11-22', 4890.46])
      expect(parser.perform.last).to eq(['2013-07-06', 79.45])
    end
  end

  context 'when selected quarterly granularity' do
    before do
      parser.granularity = :quarterly
    end

    it_behaves_like 'correct formatter'

    it 'return correct date range' do
      expect(parser.perform.first).to eq(['2018-11-22', 5206.84])
      expect(parser.perform.last).to eq(['2013-07-06', 79.45])
    end
  end

  context 'when selected date range' do
    before do
      parser.granularity = :quarterly
      parser.date_range = { filter_date_from: '2018-10-22', filter_date_to: '2018-11-21' }
    end

    it_behaves_like 'correct formatter'

    it 'return correct date range' do
      expect(parser.perform).to eq([['2018-11-21', 5355.65]])
    end
  end
end
