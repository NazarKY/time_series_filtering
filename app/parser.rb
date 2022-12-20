require 'json'
require 'date'

class Parser
  GRANULARITY_MAP = {
    weekly: :week,
    monthly: :month,
    quarterly: :quarter
  }

  QUARTER_MAP = {
    '01' => :first, '02' => :first, '03' => :first,
    '04' => :second, '05' => :second, '06' => :second,
    '07' => :third, '08' => :third, '09' => :third,
    '10' => :fourth, '11' => :fourth, '12' => :fourth
  }

  attr_accessor :order_dir, :granularity, :date_range, :filepath

  def initialize(order_dir: :desc, granularity: :daily, date_range: {}, filepath: 'data/data.json')
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
    data = sorted_dailies_date_price
    return data if granularity == :daily

    con_count = 1
    start_date = data.first.first
    con_price_sum = data.first.last

    data.each_cons(2).with_object([]) do |(prev_vals, next_vals), result|
      prev_arr_date = prev_vals.first.split('-')
      next_arr_date = next_vals.first.split('-')
      same_range = send("same_#{GRANULARITY_MAP[granularity]}_range?", prev_arr_date, next_arr_date, con_count)
      if same_range && data.last.first != next_vals.first
        con_price_sum += next_vals.last
        con_count += 1
      else
        if data.last.first == next_vals.first
          con_price_sum += next_vals.last
          con_count += 1
        end
        result << [start_date, (con_price_sum/con_count).round(2)]
        start_date = next_vals.first
        con_price_sum = next_vals.last
        con_count = 1
      end
    end
  end

  def same_week_range?(prev_arr_date, next_arr_date, con_count)
    return false unless prev_arr_date[0] == next_arr_date[0] && prev_arr_date[1] == next_arr_date[1]

    (prev_arr_date[2].to_i - next_arr_date[2].to_i).abs == 1 && con_count < 7
  end

  def same_month_range?(prev_arr_date, next_arr_date, _)
    prev_arr_date[0] == next_arr_date[0] && prev_arr_date[1] == next_arr_date[1]
  end

  def same_quarter_range?(prev_arr_date, next_arr_date, _)
    prev_arr_date[0] == next_arr_date[0] && QUARTER_MAP[prev_arr_date[1]] == QUARTER_MAP[next_arr_date[1]]
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

