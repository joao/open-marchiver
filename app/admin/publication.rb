ActiveAdmin.register Publication do

  # Role Checking
  actions :all
  controller do
    def action_methods
      if current_user.role == 'admin'
        super
      elsif current_user.role == 'publisher' || current_user.role == 'editor'
        super - ['new', 'create', 'edit', 'update', 'delete', 'destroy']
      end
    end
  end

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end


  menu priority: 2

  permit_params :name, :description, :frequency, :visible

  # Publication indexes
  index :download_links => false  do
    column "Publication" do |publication|
      link_to publication.name, admin_publication_path(publication)
    end
    column "Number of Issues" do |publication|
      publication.issues.size
    end
    column :description 
    column "Publishing Frequency", sortable: :frequency do |publication|
      publication.frequency.capitalize
    end
    column :visible
    actions
  end

  config.sort_order = 'name_asc'
  config.filters = false
  config.batch_actions = false

  # Show Publication
  show do
    number_of_issues = publication.issues.size
    attributes_table do
      row :name
      row :description
      #row :frequency
      row "Number of Issues" do |publication|
        number_of_issues
      end
      if number_of_issues != 0
        row "Issues" do |publication|
          issues = publication.issues.order(date: :desc)
          ul do
            issues.each do |issue|
              li link_to issue.date_output , admin_issue_path(issue)
            end
          end
          # if issue.files
          #   files = issue.files
          #   ul do 
          #     files.each do |file|
          #       li file.url.split('/').last
          #     end
          #   end
          # else
          #   "None"
          # end
        end # end of issues listing
      end
      row :visible
    end
  end

end
