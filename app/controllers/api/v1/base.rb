module API  
  module V1
    class Base < Grape::API

      # Issues and Publications functionality
      mount API::V1::Issues
      mount API::V1::Publications
    end
  end
end  