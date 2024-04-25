class RevenuePresenter
  def initialize(user, graph_type = 'gross_volume')
    @user = user
    @start_of_day = Date.today.beginning_of_day
    @end_of_day = Date.today.end_of_day
    @graph_type = graph_type
    @graph_data = { "00" => 0 }
    @yesterday_total_count = 0
    @total_count = 0
    @tomorrows_gross_total = 0
    @currency_sign = "£"
  end

  def call
    case @graph_type
    when "gross_volume"
      gross_volume
    when "new_customers"
      new_customers_data
    when "successful_payments"
      successful_payments
    else
      gross_volume
    end
  end

  private

  def data_formatter
    {
      graph_data: @graph_data,
      total_count: @total_count,
      yesterday_total_count: @yesterday_total_count,
      tomorrows_value: @tomorrows_gross_total,
      currency_sign: @currency_sign
    }
  end

  def gross_volume
    receipts = Receipt.where(created_at: @start_of_day...@end_of_day)

    # Graph data formatting
    amounts_per_hour =  receipts.group_by_hour(:created_at, format: "%H", range: @start_of_day...@end_of_day).sum(:amount)
    graph_data_formatter(amounts_per_hour)

    @yesterday_total_count = Receipt.where(created_at: Date.yesterday.beginning_of_day...Date.yesterday.end_of_day).sum(:amount)
    @total_count = receipts.sum(:amount)
    future_prediction_value
    # final data to return
    data_formatter
  end

  def new_customers_data
    users = User.where(created_at: @start_of_day..@end_of_day)
    count_per_hour =  users.group_by_hour(:created_at, format: "%H", range: @start_of_day...@end_of_day).count
    graph_data_formatter(count_per_hour)

    @yesterday_total_count = User.where(created_at: Date.yesterday.beginning_of_day...Date.yesterday.end_of_day).count
    @total_count = users.count
    @currency_sign = ""
    future_prediction_value
    # final data to return
    data_formatter
  end

  def successful_payments
    receipts = Receipt.where(created_at: @start_of_day..@end_of_day)

    # Graph data formatting
    amounts_per_hour =  receipts.group_by_hour(:created_at, format: "%H", range: @start_of_day..@end_of_day).count
    graph_data_formatter(amounts_per_hour)

    @yesterday_total_count = Receipt.where(created_at: Date.yesterday.beginning_of_day...Date.yesterday.end_of_day).count
    @total_count = receipts.count
    @currency_sign = ""
    future_prediction_value
    # final data to return
    data_formatter
  end

  def graph_data_formatter(data)
    last_value = 0
    data.each_slice(2).with_index do |((key1, value1), (key2, value2)), index|
      next_key = data.keys[index * 2 + 2] || "24"
      sum = value1 + value2 + last_value
      @graph_data[next_key] = sum
      last_value = sum
    end
  end

  def future_prediction_value
    percentage_change = ((@total_count - @yesterday_total_count) / @yesterday_total_count.to_f) * 100
    tomorrows_gross_total = @total_count + (@total_count * (percentage_change / 100))
    @tomorrows_gross_total = tomorrows_gross_total.nan? ? 0 : tomorrows_gross_total.to_i
  end

  def net_volume
    # Logic to calculate net volume data
  end
end
