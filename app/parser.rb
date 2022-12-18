require 'json'
require 'date'

class Parser
  GRANULARITY_MAP = {
    weekly: 7,
    monthly: 30,
    quarterly: 91
  }

  def initialize(order_dir: :asc, granularity: :daily, date: {})
    @order_dir = order_dir
    @granularity = granularity
    @date = date
  end

  def perform
    p granulated_date_price
  end

  private

  def granulated_date_price
    return sorted_dailies_date_price if @granularity === :daily

    sorted_dailies_date_price.each_slice(GRANULARITY_MAP[:weekly]).with_object([]) do |slice, result|
      granularity_val = GRANULARITY_MAP[:weekly] || slice.size
      granularity_date = "#{slice.first[:date]}..#{slice.last[:date]}"
      granularity_price = slice.inject(0.0) { |sum, day| sum + day[:price]} / granularity_val

      result << [granularity_date, granularity_price.round(2)]
    end
  end

  def sorted_dailies_date_price
    result = dailies_date_price_in_range.sort_by { |day_value| day_value[:date] }
    return result if @order_dir === :asc

    result.reverse
  end

  def dailies_date_price_in_range
    parsed_file.each_with_object([]) do |day_value, result|
      next unless present?(day_value['price(USD)']) && (filter_date_from..filter_date_to).include?(day_value['date'])

      result << { date: day_value['date'], price: day_value['price(USD)'].to_f }
    end
  end

  def filter_date_from
    @filter_date_from ||= (present?(@date[:filter_date_from]) ? @date[:filter_date_from] : "2000-01-01")
  end

  def filter_date_to
    @filter_date_to ||= (present?(@date[:filter_date_to]) ? @date[:filter_date_to] : DateTime.now.strftime('%Y-%m-%d'))
  end

  def present?(val)
    !val.nil? && !val.empty?
  end

  def parsed_file
    JSON.parse(File.read("data/data.json"))
  end
end

Parser.new(order_dir: :desc, granularity: :weekly).perform