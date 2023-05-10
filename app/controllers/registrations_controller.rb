class RegistrationsController < Devise::RegistrationsController
  def new
    redirect_to root_path, alert: "Registration is not available."
  end

  def create
    raise ActionController::RoutingError, "Registration is not available."
  end
end