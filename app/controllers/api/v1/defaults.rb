module API  
  module V1
    module Defaults
      extend ActiveSupport::Concern

      included do

        prefix "api"
        version "v1", using: :path
          
        default_format :json
        format :json
        formatter :json, Grape::Formatter::Json


        helpers do
          
          def permitted_params
            @permitted_params ||= declared(params, 
               include_missing: false)
          end

          def logger
            Rails.logger
          end

          # Check Auth Token
          def check_auth_token
            if params[:api_auth_token] == ENV['API_AUTH_TOKEN']
              return true
            end
          end

          # Authenticate, by checking if the auth_token used is correct
          def authenticate!
            error!("401 Unauthorized", 401) unless check_auth_token 
          end

        end # end of helpers

        rescue_from ActiveRecord::RecordNotFound do |e|
          error_response(message: e.message, status: 404)
        end

        rescue_from ActiveRecord::RecordInvalid do |e|
          error_response(message: e.message, status: 422)
        end
      end
    end
  end
end  