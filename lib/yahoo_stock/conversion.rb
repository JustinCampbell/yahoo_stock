module YahooStock

  class Conversion < Base

    def self.convert(parameter, data)
      # Return immediately if we're not converting anything
      return data unless @@convert

      # If we have a conversion defined for this parameter, convert it, otherwise just return the data
      if CONVERSIONS[parameter]
        self.send CONVERSIONS[parameter.to_sym], data
      else
        data
      end
    end

    CONVERSIONS = {
      # :after_hours_change_real_time
      # :annualized_gain
      # :ask
      # :ask_real_time
      :average_daily_volume => :integer,
      # :bid
      # :bid_real_time
      # :bid_size
      # :book_value
      :change => :decimal,
      # :change_from_200_day_moving_average
      # :change_from_50_day_moving_average
      # :change_from_52_week_high
      # :change_from_52_week_low
      # :change_in_percent
      # :change_percent_real_time
      # :change_real_time
      # :change_with_percent_change
      # :commission
      :day_high => :decimal,
      :day_low => :decimal,
      # :day_range
      # :day_range_real_time
      # :day_value_change
      # :day_value_change_real_time
      :dividend_pay_date => :date,
      :dividend_per_share => :decimal,
      :dividend_yield => :decimal,
      # :earnings_per_share
      :ebitda => :integer,
      # :eps_estimate_current_year
      # :eps_estimate_next_quarter
      # :eps_estimate_next_year
      :ex_dividend_date => :date,
      # :fifty_day_moving_average
      :fifty_two_week_high => :decimal,
      :fifty_two_week_low => :decimal,
      # :fifty_two_week_range
      # :high_limit
      # :holdings_gain
      # :holdings_gain_percent
      # :holdings_gain_percent_real_time
      # :holdings_gain_real_time
      # :holdings_value
      # :holdings_value_real_time
      # :last_trade_date
      # :last_trade_price_only
      # :last_trade_real_time_with_time
      # :last_trade_time
      # :last_trade_with_time
      # :low_limit
      :market_capitalization => :integer,
      # :market_cap_real_time
      # :more_info
      # :name
      # :notes
      # :one_yr_target_price
      :open => :decimal,
      # :order_book_real_time
      # :peg_ratio
      # :percent_change_from_200_day_moving_average
      # :percent_change_from_50_day_moving_average
      # :percent_change_from_52_week_high
      # :percent_change_from_52_week_low
      :previous_close => :decimal,
      # :price_eps_estimate_current_year
      # :price_eps_estimate_next_year
      # :price_paid
      # :p_e_ratio
      # :p_e_ratio_real_time
      # :shares_owned
      # :short_ratio
      # :stock_exchange
      # :symbol
      # :ticker_trend
      :trade_date => :date,
      # :two_hundred_day_moving_average
      :volume => :integer
    } unless defined? CONVERSIONS

    protected

    # Converts strings to dates. Supports YY before 1970, and dates expressed as MMM dd (Jan  1)
    def self.date(string)
      if matchdata = string.match(/([A-Za-z]{3}) {1,2}([0-9]{1,2})/)
        month = Date.strptime(matchdata[1],"%b").month
        day   = matchdata[2]
        year  = Date.today.year.to_s
      else
        date  = string.split('/')
        month = date[0]
        day   = date[1]
        year  = date[2] or Date.today.year.to_s
      end

      case year.length
      when 4
        yyyy = year
      when 2
        # If the 2 digit year is in the future, treat it as 19xx
        yyyy = year > Date.today.year.to_s[2,2] ? "19" << year : "20" << year
      end

      # Return properly parsed date
      Date.strptime "#{month}/#{day}/#{yyyy}", '%m/%d/%Y'
    end

    # Converts strings to BigDecimal objects
    def self.decimal(string)
      BigDecimal.new string
    end

    # Converts strings ending with a large number abbreviation to integers
    def self.integer(string)

      # Remove commas from the string
      string.delete! ","

      # Check if we're converting from a big number suffix
      if %w[B M K].include? string[-1,1]

        # Set the multiplier by the suffix
        multiplier = case string[-1,1]
          when "B" then 1_000_000_000
          when "M" then 1_000_000
          when "K" then 1_000
          else 1
        end

        # Multiply the remaining string and convert to an integer
        (BigDecimal.new(string) * multiplier).to_i

      else

        # Try to convert the string to an integer
        string.to_i

      end

    end

  end

end
