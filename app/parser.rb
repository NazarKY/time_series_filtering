require 'json'
require 'date'

class Parser
  def initialize(order_dir: :asc, granularity: :daily, date: {})
    @order_dir = order_dir
    @granularity = granularity
    @date = date
  end

  def perform
    p sorted_dailies_date_price
    p sorted_dailies_date_price.size
  end

  private

  def sorted_dailies_date_price
    result = dailies_date_price_in_range.sort_by { |_, val| val }
    return result if @order_dir === :asc

    result.reverse
  end

  def dailies_date_price_in_range
    parsed_file.each_with_object([]) do |day_value, result|
      next unless present?(day_value['price(USD)']) && (filter_date_from..filter_date_to).include?(day_value['date'])

      result << { date: day_value['date'], price: day_value['price(USD)'] }
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

Parser.new(order_dir: :desc).perform