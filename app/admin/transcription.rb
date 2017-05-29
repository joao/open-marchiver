ActiveAdmin.register_page "Transcription" do

  # Role Checking
  # actions :all
  # controller do
  #   def action_methods
  #     if current_admin.role == 'admin'
  #       super
  #     elsif current_admin.role == 'publisher'
  #       super - ['new', 'create', 'destroy']
  #     elsif current_admin.role == 'editor'
  #       super - ['new', 'edit', 'update', 'create', 'destroy']
  #     end
  #   end
  # end

  menu label: "Transcriptions", priority: 4


  content title: "Transcriptions" do
    div class: "blank_slate_container" do
      span class: "blank_slate" do
        small "Transcriptions admnistration customized for your users." #I18n.t("active_admin.dashboard_welcome.call_to_action")
      end
    end
  end
end