module ApplicationHelper
  def humanize_status(status)
    case status
    when "in_progress"
      "In Progress"
    when "pending"
      "Pending"
    when "completed"
      "Completed"
    when "individual"
      "Individual"
    when "dealer"
      "Dealer"
    when "approved"
      "Approved"
    when "rejected"
      "Rejected"
    when "admin"
      "Super Admin"
    else
      status.blank? ? "N/A" : status
    end
  end
end
