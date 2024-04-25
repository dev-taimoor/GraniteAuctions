class RevenuesController < ApplicationController
  def index
    @dashboard_presenter = RevenuePresenter.new(current_user, params[:graph_type])
    @reports_presenter = ReportsGraphPresenter.new(params)
    @data = @dashboard_presenter.call
    @reports_data = @reports_presenter.call
  end

  def download_reports
    csv_file = Reports::RevenueReportService.new.generate_csv(params)
    send_data csv_file, filename: 'report.csv', type: 'text/csv'
  end
end
