class ReportsGraphPresenter
  def initialize(params)
    @reports_period = params[:report_period] || "last_12_months"
    create_dates(params)
    @group_by = params[:group_by] || "month"
    @receipts = Receipt.where(created_at: @start_date..@end_date)
    @previous_receipts = Receipt.where(created_at: @previous_start_date..@previous_end_date) if params[:start_date].blank?
    @users = User.where(created_at: @start_date..@end_date)
    @previous_users = User.where(created_at: @start_date..@end_date) if params[:start_date].blank?
  end

  def call
    # Initialize graph data arrays
    gross_graph_data = [gross_volume_graph_data]
    customer_graph_data = [new_customer_graph_data]
    payment_graph_data = [current_payment_graph_data]
  
    # Append previous graph data if present
    append_previous_data(gross_graph_data, customer_graph_data, payment_graph_data) if @previous_start_date.present?

    result = {
      gross_volume_graph: gross_graph_data,
      gross_total: gross_volume_amount,
      new_customer_graph: customer_graph_data,
      customer_count: @users.count,
      payment_graph: payment_graph_data,
      payment_count: @receipts.count
    }
  
    # Append previous counts if present
    append_previous_counts(result) if @previous_start_date.present?
  
    return result
  end

  private

  # Gross Volume Graph calculation on previous and current data
  def gross_volume_graph_data
    send("group_by_#{@group_by}", @receipts, @start_date, @end_date).sum(:amount)
  end

  def previous_gross_volume_graph_data
    send("group_by_#{@group_by}", @previous_receipts, @previous_start_date, @previous_end_date).sum(:amount)
  end

  def gross_volume_amount
    @receipts.sum(:amount) || 0
  end

  def previous_gross_volume_amount
    @previous_receipts.sum(:amount)
  end
  # Gross Volume data calculation end

  # New Customer Graph calculation on previous and current data start
  def new_customer_graph_data
    send("group_by_#{@group_by}", @users, @start_date, @end_date).count
  end

  def previous_new_customer_graph_data
    send("group_by_#{@group_by}", @previous_users, @previous_start_date, @previous_end_date).count
  end
  # new customer data calculation end

  # Successfull Payments Graph calculation on previous and current data
  def current_payment_graph_data
    send("group_by_#{@group_by}", @receipts, @start_date, @end_date).count
  end

  def previous_payment_graph_data
    send("group_by_#{@group_by}", @previous_receipts, @previous_start_date, @previous_end_date).count
  end
  # successfull payments data calculation end

  def group_by_month(data, start_date, end_date)
    data.group_by_month(:created_at, format: "%B", range: start_date..end_date)
  end

  def group_by_week(data, start_date, end_date)
    data.group_by_week(:created_at, format: "%W", range: start_date..end_date)
  end

  def group_by_day(data, start_date, end_date)
    data.group_by_day(:created_at, format: "%-d %b", range: start_date..end_date)
  end

  def create_dates(params)
    @current_date = Time.now.beginning_of_day
    @start_date = params[:start_date].present? ? DateTime.parse(params[:start_date]) : calculate_start_date
    @end_date = params[:end_date].present? ? DateTime.parse(params[:end_date]) : @current_date
    if params[:start_date].blank?
      @previous_start_date = calculate_start_date(2)
      @previous_end_date = @start_date
    end
  end

  def calculate_start_date(previous_period_multiplier = 1)
    case @reports_period
    when "last_6_months"
      @current_date - (6.months * previous_period_multiplier)
    when "last_month"
      @current_date - (1.month * previous_period_multiplier)
    else
      @current_date - (1.year * previous_period_multiplier)
    end
  end

  def append_previous_data(gross_graph_data, customer_graph_data, payment_graph_data)
    gross_graph_data << previous_gross_volume_graph_data
    customer_graph_data << previous_new_customer_graph_data
    payment_graph_data << previous_payment_graph_data
  end

  def append_previous_counts(result)
    result[:previous_total] = previous_gross_volume_amount
    result[:previous_customer_count] = @previous_users.count
    result[:previous_payment_count] = @previous_receipts.count
  end
end
