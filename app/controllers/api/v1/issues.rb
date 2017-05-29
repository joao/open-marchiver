module API  
  module V1
    class Issues < Grape::API


      include API::V1::Defaults

      resource :issues do

        # Get all Issues, not needed for now
        #desc "Return all issues"
        #get "/", root: :issue do
          #authenticate!
        # Issue.all
        #end


        # Get an Issue
        desc "Return a issue"
        params do
          requires :id, type: String, desc: "ID of issue"
        end
        get ":id", root: "issue" do
          #authenticate!
          issue = Issue.where(id: permitted_params[:id]).first

          return {
              'id': issue.id,
              'publication_id': issue.publication_id,
              'date': issue.date,
              'width': issue.width,
              'height': issue.height,
              'minZoom': issue.minZoom,
              'maxZoom': issue.maxZoom,
              'number_of_pages': issue.number_of_pages,
              'page_width': issue.page_width,
              'pages_widths_and_heights': issue.pages_widths_and_heights
          }

        end



        # Get all issues of a Publication year
        desc "Return a year of issues"
        params do
          requires :publication_id, type: String, desc: "ID of Publication"
          requires :year, type: String, desc: "Year"
        end
        get ":publication_id/year/:year", root: "issue" do
          publication_id = permitted_params[:publication_id]
          year = permitted_params[:year]

          # Old version from Marchiver v0.5
          year_issues_json = {months: []}
          # Get unique months in a year
          year_issues = Issue.old_of_year( year ).where( tiles_generated: true, publication_id: publication_id).select("DISTINCT MONTH(date) as month")
          
          year_issues.each  do |issue_month|

            month = "%.2d" % issue_month.month.to_i

            year_issues_json[:months] << {
                 "month": month,
                 "issues": Issue.old_of_year(year).where("MONTH(date) = ?", month).where(tiles_generated: true, publication_id: publication_id).order('date ASC').select("id, DAY(date) as day")
               }

          end # end of iterating through the year's issues

         # Return JSON
         return year_issues_json

        end
        

        # Get all issues of a Publication year + month
        desc "Return a year + month of issues"
        params do
          requires :publication_id, type: String, desc: "ID of Publication"
          requires :year, type: String, desc: "Year"
          requires :month, type: String, desc: "Month"
        end
        get ":publication_id/year/:year/month/:month", root: "issue" do
          publication_id = permitted_params[:publication_id]
          year = permitted_params[:year]
          month = permitted_params[:month]
          Issue.of_year_and_month(publication_id, year, month)
        end


        # Get mJSON
        desc "Return mJSON"
        params do
          requires :issue_id, type: String, desc: "Issue ID"
          requires :page_number, type: String, desc: "Page Number"
        end
        get ":issue_id/page/:page_number/mjson", root: "issue" do
          issue_id = permitted_params[:issue_id]
          page_number = permitted_params[:page_number]

          page = Page.where(issue_id: issue_id, number: page_number).pluck(:id)

          mjson = Page.where(issue_id: issue_id, number: page_number).first.to_mjson
          
          if mjson
            return mjson
          else 
            return "{ error: '#{issue_id} #{page_number} This page doesn't have OCR or text processed.' }"
          end
          
        end



        # Upload an Issue via publication
        # Requires an api_auth_token that is defined in config/application.yml
        # A token can be generated in the command line by running rails secret,
        # and placing it in the file above
        desc "Upload an issue"
        params do
          requires :publication_name, type: String, desc: "Publication name"
          requires :date, type: DateTime, desc: "Date of Issue Publication"
          requires :file, type: File, desc: "PDF file of Issue"
          requires :api_auth_token, type: String, desc: 'API Auth Token'
        end
        post do
          authenticate!
          publication_id = Publication.find_by_name(params[:publication_name]).id
          Issue.create!({
            publication_id: publication_id,
            date: params[:date],
            file: params[:file]
            })
        end

      end # end of resource
    end
  end
end  