module API  
  module V1
    class Publications < Grape::API

      include API::V1::Defaults


      resource :publications do

        # Get all Publications
        desc "Return all Publications"
        get "", root: :publications do
          #authenticate!
          Publication.where(:visible => true).as_json(only: ['id', 'name', 'frequency'])
        end

        # Get a Publication details
        desc "Return a Publication"
        params do
          requires :id, type: String, desc: "ID of Publication"
        end
        get ":id", root: :publications do
          publication_id = permitted_params[:id]
          Publication.where(id: publication_id).as_json(only: ['id', 'name', 'frequency', 'visible'])
        end


        # Get all Years of Issues of a Publication
        desc "Return all Years of a Publication"
        params do
          requires :id, type: String, desc: "ID of Publication"
        end
        get ":id/years", root: :publications do
          publication_id = permitted_params[:id]
          Publication.unique_years(publication_id).as_json
        end


        # Get all Issue_ids of a Publication
        desc "Return all Issues of a Publication"
        params do
          requires :id, type: String, desc: "ID of Publication"
        end
        get ":id/issues", root: :publications do
          publication_id = permitted_params[:id]
          Issue.where(publication_id: publication_id).as_json(only: [ 'id'])
        end


      end # end of resource
    end
  end
end  