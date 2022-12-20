require_relative 'app/parser'

def time_series_filtering(order_dir: :desc, filter_date_from: nil, filter_date_to: nil, granularity: :daily)
  date_range = { filter_date_from: filter_date_from, filter_date_to: filter_date_to }
  Parser.new(order_dir: order_dir, granularity: granularity, date_range: date_range).perform
end
