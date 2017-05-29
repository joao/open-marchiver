class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  # Only using Facebook for now
  # Can be adaptaded to other social networks and providers
  # https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview
  def facebook
     @user = User.from_omniauth(request.env["omniauth.auth"])
     sign_in_and_redirect @user
  end

end