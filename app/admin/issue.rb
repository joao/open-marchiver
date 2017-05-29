ActiveAdmin.register Issue do

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
#https://pinboard.in/add/?url=https%3A%2F%2Fgist.github.com%2Femaiax%2F4163861&title=Rake+Tasks+for+Carrier+Wave+for+reprocessing+versions.+%C2%B7+GitHub&later=&next=same
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

  batch_action :destroy

  menu priority: 3

  permit_params :publication_id, :date, :file# {files: []}

  index :download_links => false  do
    column "Publication" do |issue|
      link_to issue.publication.name, admin_issue_path(issue)
    end
    #column :number
    column "Date", :date_output, sortable: true
    column "Pages", sortable: true do |issue|
      issue.pages.size
    end
    #column :year
    #column :year_number
    column "Tiles Processed", :tiles_generated
    column "PDF type", :pdf_type
    # column "Number of Issues" do |publication|
    #   publication.issues.size
    # end
    # column :description 
    # column "Publishing Frequency", :frequency
    actions
  end

  filter :publication
  filter :date, :as => :date_range, datepicker_options: { changeMonth: true, changeYear: true }

  config.sort_order = 'date_desc'
  config.filters = true
  config.batch_actions = false


  #form html: { multipart: true } do |f|
  form do |f|
    f.semantic_errors # shows errors on :base
    inputs do
      f.input :publication
      f.input :date, as: :datepicker, datepicker_options: { changeYear: true, changeMonth: true, yearRange: "1800:" + (Date.today.year + 1).to_s}
      #f.input :file, as: :file, input_html: { multiple: true}
      f.input :file, as: :file
      #f.inputs          # builds an input field for every attribute
    end
    f.actions         # adds the 'Submit' and 'Cancel' buttons
  end

  # Show Issue
  show title: :name_plus_date do
    attributes_table do
      row :publication
      row "Date" do |issue|
        issue.date_output
      end
      row "Number of Pages" do |issue|
        issue.pages.size
      end
      row "File" do |issue|
        issue.file.file.filename
      end
      # row "File" do |issue|
      #   if issue.file
      #     file = issue.file
      #     ul do 
      #       file.each do |file|
      #         li file.url.split('/').last
      #       end
      #     end
      #   else
      #     "None"
      #   end
      #   #issue.files? ? issue.files[0].url : "None"
      #   #issue.files ? issue.files[0].identifier : "None"
      # end
    end
    if issue.tiles_generated == true
      render 'view', {issue: issue}
    end
  end

end
