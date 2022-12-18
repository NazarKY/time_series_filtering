require 'json'
require 'date'

class Parser
  GRANULARITY_MAP = {
    weekly: 7,
    monthly: 30,
    quarterly: 91
  }

  attr_accessor :order_dir, :granularity, :date_range, :filepath

  def initialize(order_dir: :asc, granularity: :daily, date_range: {}, filepath: 'data/data.json')
    @date_range = date_range
    @filepath = filepath
    @order_dir = order_dir
    @granularity = granularity
  end

  def perform
    granulated_date_price
  end

  private

  def granulated_date_price
    return sorted_dailies_date_price if granularity === :daily

    sorted_dailies_date_price.each_slice(GRANULARITY_MAP[granularity]).with_object([]) do |slice, result|
      granularity_val = GRANULARITY_MAP[granularity] || slice.size
      granularity_date = "#{slice.first.first}..#{slice.last.first}"
      granularity_price = slice.inject(0.0) { |sum, day| sum + day.last} / granularity_val

      result << [granularity_date, granularity_price.round(2)]
    end
  end

  def sorted_dailies_date_price
    result = dailies_date_price_in_range.sort_by { |day_value| day_value.first }
    return result if order_dir === :asc

    result.reverse
  end

  def dailies_date_price_in_range
    parsed_file.each_with_object([]) do |day_value, result|
      next unless present?(day_value['price(USD)']) && day_in_date_range(day_value['date'])

      result << [ day_value['date'], day_value['price(USD)'].to_f ]
    end
  end

  def day_in_date_range(day)
    filter_date_from <= day && day <= filter_date_to
  end

  def filter_date_from
    @filter_date_from ||= (present?(date_range[:filter_date_from]) ? date_range[:filter_date_from] : "2000-01-01")
  end

  def filter_date_to
    @filter_date_to ||= (present?(date_range[:filter_date_to]) ? date_range[:filter_date_to] : DateTime.now.strftime('%Y-%m-%d'))
  end

  def present?(val)
    !val.nil? && !val.empty?
  end

  def parsed_file
    JSON.parse(File.read(filepath))
  end
end
