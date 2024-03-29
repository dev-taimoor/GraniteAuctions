module ApplicationHelper
  def humanize_status(status)
    case status
    when "in_progress"
      "In Progress"
    when "pending"
      "Pending"
    when "completed"
      "Completed"
    else
      status
    end
  end
end
