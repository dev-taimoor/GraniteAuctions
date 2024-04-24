# frozen_string_literal: true
require 'csv'
class Reports::RevenueReportService
  def generate_csv(params)
    csv_data = generate_data(params)
    CSV.generate(headers: true) do |csv|
      csv_data.each do |row|
        csv << row
      end
    end
  end
  private

  def generate_data(params)
    start_date, end_date = calculate_dates(params)
    csv_data = [["Name", "Email", "Invoice ID", "Created At", "Invoice Type", "Amount", "Delivery Cost", "Vat Amount", "Car Id"]]
    Receipt.where(created_at: start_date..end_date).joins(:user).each do |receipt|
      invoice_type = receipt.car_id.present? ? "Purchase" : "Subscription"
      csv_data << [receipt.user.full_name, receipt.user.email, receipt.invoice_id, receipt.created_at.to_date, invoice_type, receipt.amount, receipt.delivery_cost, receipt.vat_amount.to_i, receipt.car_id ]
    end
    csv_data
  end

  def calculate_dates(params)
    if params[:start_date].present? && params[:end_date].present?
      return [params[:start_date], params[:end_date]]
    else
      start_date = calculate_start_date(params[:report_period])
      return [start_date, Time.now]
    end
  end

  def calculate_start_date(report_period)
    current_date = Time.now.beginning_of_day
    case report_period
    when "last_6_months"
      current_date - (6.months)
    when "last_month"
      current_date - (1.month)
    else
      current_date - (1.year)
    end
  end
end
