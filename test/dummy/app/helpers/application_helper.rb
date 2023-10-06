module ApplicationHelper
  def current_user
    if session.present?
      "user@example.com"
    end
  end
end
