class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :require_authentication_for_writes

  helper_method :current_or_demo_user

  private

  def current_or_demo_user
    if user_signed_in?
      current_user
    else
      @demo_user ||= User.find_by(demo: true)
    end
  end

  def require_authentication_for_writes
    return if user_signed_in?
    return if request.get? || request.head?

    redirect_to root_path, alert: "This app is for demo only, save is not allowed."
  end
end
