# Time Series Filtering

## To run

```
irb
require_relative 'main'
time_series_filtering() # execute with default params

# execute with seted params
time_series_filtering(order_dir: val, filter_date_from: val, filter_date_to: val, granularity: val) 
```

## To run tests

``rspec spec``

## What can be improved
1. Possibly this implementation is not with the best performance - I haven't been testing with huge files
2. ...
