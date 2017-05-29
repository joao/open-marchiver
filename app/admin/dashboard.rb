ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    # div class: "blank_slate_container", id: "dashboard_default_message" do
    #   span class: "blank_slate" do
    #     span I18n.t("active_admin.dashboard_welcome.welcome")
    #     small I18n.t("active_admin.dashboard_welcome.call_to_action")
    #   end
    # end

    # Here is an example of a simple dashboard with columns and panels.
    #

    # 1st row of admin columns
    columns do

      # Last transcriptions
      column do
        panel "Latest Transcriptions Corrections" do

        end

      end

    # Recent Uploaded Issues
      column do
        panel "Latest Issues Uploaded" do
          ul do
            Issue.where('tiles_generated = 1').order('id DESC').limit(5).map do |issue|
              li "#{issue.publication.name} - #{link_to issue.date_output, admin_issue_path(issue)}".html_safe
            end
          end
        end
      end

      # Jobs process status
      column do
        panel "Issues being processed" do
            issues = Issue.where('tiles_generated IS NULL').size
            if issues > 0
               "#{issues} issues being processed."
            else
                "No issues being processed."
            end
        end
      end

    end

    columns do
      # Latest Registrations
      column do
        panel "Latest Registrations" do
          ul do
            User.order('id DESC').limit(10).map do |user|
              li user.name
              #li (link_to (image_tag(user.image) + " " + user.name) , admin_user_path(user))
            end
          end
        end
      end

      # Statistics
      column do
        panel "Statistics" do
          h3 "Publications"
          ul do
            li "Total Publications: " + Publication.count.to_s
            li "Total Issues: " + Issue.count.to_s
            li "Total Pages: " + Page.count.to_s
          end
          h3 "Users"
          ul do
            li "Total Users: " + User.count.to_s
          end
        end
      end

    end



  end # content
end
