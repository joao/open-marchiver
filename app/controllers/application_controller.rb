class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # Reset app locale, so that ActiveAdmin doesn't override it
  # Use as before_action in controllers
  def reset_app_locale
    I18n.locale = ENV['UI_LANGUAGE'].to_sym
  end

  # ActiveAdmin always set to english
  def set_admin_locale
    I18n.locale = :en
  end



  private

  # Default sign_in and sign_out (:delete method) for users
  def after_sign_in_path_for(resource)
    if current_user.is_admin?
      session["user_return_to"] || admin_root_path || root_path
    else 
      session["user_return_to"] || corrector_path || root_path
    end
    # if resource.class == User
    #   request.env['omniauth.origin'] || corrector_path || root_path
    # elsif resource.class == Admin
    #   request.env['omniauth.origin'] || admin_root_path || root_path
    # end
  end

  def after_sign_out_path_for(resource)
    session["user_return_to"] || root_path
    # if resource.to_s == 'user'
    #   corrector_path || root_path
    # elsif resource.to_s == 'admin'
    #   admin_root_path || root_path
    # end
  end

  # ActiveAdmin Verificaiton
  def authenticate_admin_user!
    if current_user == nil
      # No current_user? Let's ask to login then
      redirect_to new_user_session_path
    elsif !current_user.is_admin?
      # Not an Admin? redirect to Corretor
      redirect_to corrector_path
    elsif current_user.is_admin?
      # Do nothing, it's an Admin
    else
      # Any other case, let's redirect to corrector anyway
      redirect_to corrector_path
    end
  end

end
